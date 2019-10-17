require 'test_helper'
require 'json'

module Orchestrator
  class PipelineClientTest < Minitest::Test
    def test_shortcut_method_works
      arg1 = mock
      arg2 = mock
      client = mock
      client.expects(:run_tests).with(arg1, arg2)
      PipelineClient.expects(:new).returns(client)
      PipelineClient.run_tests(arg1, arg2)
    end

    def test_things_run_as_expected
      track_slug = "ruby"
      exercise_slug = "two-fer"
      test_run_id = SecureRandom.uuid
      s3_uri = "s3://#{SecureRandom.uuid}"
      address = mock

      msg = {
        action: :test_solution,
        id: test_run_id,
        track_slug: track_slug,
        exercise_slug: exercise_slug,
        s3_uri: s3_uri,
        container_version: "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb",
      }
      recv_result = 1
      result = {"some" => "response"}

      zmq_socket = mock
      zmq_socket.expects(:setsockopt).with(ZMQ::LINGER, 0)
      zmq_socket.expects(:setsockopt).with(ZMQ::RCVTIMEO, 10000)
      zmq_socket.expects(:connect).with(address)
      zmq_socket.expects(:send_string).with(msg.to_json)
      zmq_socket.expects(:recv_string).with {|response|
        response << {"status": "all good", "result": result}.to_json
      }.returns(recv_result)
      zmq_socket.expects(:close)

      zmq_context = mock
      zmq_context.expects(:socket).with(ZMQ::REQ).returns(zmq_socket)
      ZMQ::Context.expects(:new).with(1).returns(zmq_context)

      client = PipelineClient.new(address: address)
      assert_equal result, client.run_tests(track_slug, exercise_slug, test_run_id, s3_uri)
    end
  end
end


