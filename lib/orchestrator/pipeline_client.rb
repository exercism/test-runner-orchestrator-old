require 'objspace'

class ContainerRunnerError < RuntimeError
end

class ContainerTimeoutError < ContainerRunnerError
end

class ContainerWorkerUnavailableError < ContainerRunnerError
end

class FailedRequest < ContainerRunnerError
end

class PipelineClient

  TIMEOUT_SECS = 20
  # ADDRESS = "tcp://analysis-router.exercism.io:5555"
  ADDRESS = "tcp://localhost:5555"

  def initialize(address: ADDRESS)
    @address = address
    @socket = open_socket

    # CCARE - when do we actually want to close the socket?
    # Is it after each send_recv, or just after the tests are
    # run, or when the pipeline client is GC'd?
    #ObjectSpace.define_finalizer(self, proc {
    #  socket.setsockopt(ZMQ::LINGER, 0)
    #  socket.close
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

  def run_tests(track_slug, exercise_slug, test_run_id, s3_uri, container_version)
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
    send_recv(params)
  end

  def build_container(track_slug, container_type, reference)
    send_recv({
      action: :build_container,
      track_slug: track_slug,
      channel: container_type,
      git_reference: reference #"d88564f01727e76f3ddea93714bdf2ea45abef86"
      # git_reference: "039f2842cabcfdc66f7f96573144e8eb255ec6e1" #bd8a0a593fa647c5bdd366080fc1e20c1bda7cb9
    }, 300)
  end

  def configure_containers(track_slug, container_type, versions)
    send_recv({
      action: :update_container_versions,
      track_slug: track_slug,
      channel: container_type,
      versions: versions
    }, 300)
  end

  def enable_container(track_slug, container_type, new_version)
    send_recv({
      action: :deploy_container_version,
      track_slug: track_slug,
      channel: container_type,
      new_version: new_version
    }, 300)
  end

  def unload_container(track_slug, container_type, new_version)
    send_recv({
      action: :unload_container_version,
      track_slug: track_slug,
      channel: container_type,
      new_version: new_version
    }, 300)
  end

  private

  attr_reader :address, :socket

  def send_recv(payload, timeout=TIMEOUT_SECS)
    # Get a response. Raises if fails
    resp = send_msg(payload.to_json, timeout)
    # Parse the response and return the results hash
    parsed = JSON.parse(resp)
    #pp parsed
    # raise FailedRequest.new("failed request") unless parsed["status"]["ok"]
    parsed
  rescue => e
    puts "Send_recv failed with #{e.message}"
    raise
  end

  def open_socket
    ZMQ::Context.new(1).socket(ZMQ::REQ).tap do |socket|
      socket.setsockopt(ZMQ::LINGER, 0)
      socket.connect(address)
    end
  end

  def send_msg(msg, timeout)
    timeout_ms = timeout * 1000
    socket.setsockopt(ZMQ::RCVTIMEO, timeout_ms)
    socket.send_string(msg)

    # Get the response back from the runner
    recv_result = socket.recv_string(response = "")

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

    # Return the response
    response
  end
end
