require 'objspace'

class PipelineClient

  ADDRESS = "tcp://analysis-router.exercism.io:5555"
  #ADDRESS = "tcp://localhost:5555"

  # Is this any safer as a constant?
  def self.zmq_context
    @zmq_context ||= Concurrent::MVar.new(ZMQ::Context.new(1))
  end

  def initialize(address: ADDRESS)
    @address = address
    @socket = open_socket

    # CCARE - when do we actually want to close the socket?
    # Is it after each send_recv, or just after the tests are
    # run, or when the pipeline client is GC'd?
    #ObjectSpace.define_finalizer(self, proc {
    #})
  end

  def restart_workers!
    send_recv({
      action: :restart_workers
    })
  end

  def reload_config!
    send_recv({
      action: :reload_config
    })
  end

  def current_config
    send_recv({
      action: :current_config
    })
  end

  def list_available_containers(track_slug, container_type)
    send_recv({
      action: :list_available_containers,
      track_slug: track_slug,
      channel: container_type
    })
  end

  def run_tests(track_slug, exercise_slug, s3_uri, container_version)
    test_run_id = "test-#{Time.now.to_i}"
    params = {
      action: :test_solution,
      id: test_run_id,
      track_slug: track_slug,
      exercise_slug: exercise_slug,
      s3_uri: s3_uri,
      container_version: container_version
      # "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb",
      # container_version: "sha-122a036658c815c2024c604046692adc4c23d5c1",
    }
    timeout = Orchestrator::TRACKS[track_slug][:timeout]
    params[:execution_timeout] = timeout / 1000
    client_timeout = timeout + 2000
    send_recv(params, client_timeout)
  end

  def build_container(track_slug, container_type, reference)
    send_recv({
      action: :build_container,
      track_slug: track_slug,
      channel: container_type,
      git_reference: reference #"d88564f01727e76f3ddea93714bdf2ea45abef86"
      # git_reference: "039f2842cabcfdc66f7f96573144e8eb255ec6e1" #bd8a0a593fa647c5bdd366080fc1e20c1bda7cb9
    }, 300_000)
  end

  def configure_containers(track_slug, container_type, versions)
    send_recv({
      action: :update_container_versions,
      track_slug: track_slug,
      channel: container_type,
      versions: versions
    }, 300_000)
  end

  def enable_container(track_slug, container_type, new_version)
    send_recv({
      action: :deploy_container_version,
      track_slug: track_slug,
      channel: container_type,
      new_version: new_version
    }, 300_000)
  end

  def unload_container(track_slug, container_type, new_version)
    send_recv({
      action: :unload_container_version,
      track_slug: track_slug,
      channel: container_type,
      new_version: new_version
    }, 300_000)
  end

  def close_socket
    #socket.setsockopt(ZMQ::LINGER, 1)
    socket.close
  end

  private

  attr_reader :address, :socket

  def send_recv(payload, timeout=20_000)
    resp = send_msg(payload.to_json, timeout)
    JSON.parse(resp)
  rescue => e
    puts "Send_recv failed with #{e.message}"
    raise
  end

  def open_socket
    # Although this is never used outside of this method,
    # it must be set as an instance variable so that it
    # doesn't get garbage collected accidently.

    socket = PipelineClient.zmq_context.borrow do |context|
      context.socket(ZMQ::REQ)
    end

    socket.linger = 1
    socket.connect(address)
    socket
  end

  def send_msg(json, timeout_ms)
    socket.linger = timeout_ms / 2
    socket.rcvtimeo = timeout_ms

    msg = ZMQ::Message.new
    msg.push(ZMQ::Frame.new(json))

    puts "Sending msg"
    socket.send_message(msg)

    # Get the response back from the runner
    puts "Waiting for response"
    recvd_msg = socket.recv_message

    puts "Got message"
    puts recvd_msg

    response = recvd_msg.pop.data
    puts "Got response"
    puts response

=begin
    # Guard against errors
    if recv_result < 0
      puts "Errored with error: #{recv_result} | #{ZMQ::Util.errno}"
      raise ContainerTimeoutError
    end

    case recv_result
    when 20
      puts "Errored with error: 20 | #{ZMQ::Util.errno}"
      raise ContainerTimeoutError
    when 31
      puts "Errored with error: 32 | #{ZMQ::Util.errno}"
      raise ContainerWorkerUnavailableError
    end
=end

    # Return the response
    response
  end
end
