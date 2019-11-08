require 'ffi-rzmq'
require 'json'
require 'yaml'
require 'securerandom'

class PipelineClient

  TIMEOUT_SECS = 10
  ADDRESS = "tcp://analysis-router.exercism.io:5555"

  def self.run_tests(*args)
    new.run_tests(*args)
  end

  def initialize(address: ADDRESS)
    @address = address
    @socket = open_socket
  end

  def run_tests(track_slug, exercise_slug, test_run_id, s3_uri)
    params = {
      action: :test_solution,
      id: test_run_id,
      track_slug: track_slug,
      exercise_slug: exercise_slug,
      s3_uri: s3_uri,
      container_version: "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb",
    }

    # Get a response. Raises if fails
    resp = send_msg(params.to_json, TIMEOUT_SECS)
    # Parse the response and return the results hash
    JSON.parse(resp)
  ensure
    close_socket
  end

  private

  attr_reader :address, :socket

  def open_socket
    ZMQ::Context.new(1).socket(ZMQ::REQ).tap do |socket|
      socket.setsockopt(ZMQ::LINGER, 0)
      socket.connect(address)
    end
  end

  def close_socket
    socket.close
  end

  def send_msg(msg, timeout)
    timeout_ms = timeout * 1000
    socket.setsockopt(ZMQ::RCVTIMEO, timeout_ms)
    socket.send_string(msg)

    # Get the response back from the runner
    recv_result = socket.recv_string(response = "")

    # Guard against errors
    raise TestRunnerTimeoutError if recv_result < 0
    case recv_result
    when 20
      raise TestRunnerTimeoutError
    when 31
      raise TestRunnerWorkerUnavailableError
    end

    # Return the response
    response
  end
end
