require 'test_helper'
require 'json'

module Orchestrator
  class PipelineClientTest < Minitest::Test
    def test_things_run_as_expected
      Timecop.freeze do
        track_slug = :ruby
        exercise_slug = "two-fer"
        s3_uri = "s3://#{SecureRandom.uuid}"
        address = mock
        container_version = "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

        msg = {
          action: :test_solution,
          id: "test-#{Time.now.to_i}",
          track_slug: track_slug,
          exercise_slug: exercise_slug,
          s3_uri: s3_uri,
          container_version: container_version,
          execution_timeout: 3
        }
        recv_result = 1
        result = {"some" => "response"}
        resp = {"status" => "all good", "result" => result}
        response_message = mock(pop: mock(data: resp.to_json))

        message = mock
        message_frame = mock
        message.expects(:push).with(message_frame)
        ZMQ::Message.expects(:new).returns(message)
        ZMQ::Frame.expects(:new).with(msg.to_json).returns(message_frame)

        zmq_socket = mock
        zmq_socket.expects(:linger=).with(1)
        zmq_socket.expects(:linger=).with(2500)
        zmq_socket.expects(:rcvtimeo=).with(5000)
        zmq_socket.expects(:connect).with(address)
        zmq_socket.expects(:send_message).with(message)
        zmq_socket.expects(:recv_message).returns(response_message)

        zmq_context = mock
        zmq_context.expects(:socket).with(ZMQ::REQ).returns(zmq_socket)
        ZMQ::Context.expects(:new).with(1).returns(zmq_context)

        client = PipelineClient.new(address: address)
        assert_equal resp, client.run_tests(track_slug, exercise_slug, s3_uri, container_version)

        # See comment in PipelineClient
        #
        #zmq_socket.expects(:close)
        # Force GC to close socket
        #client = nil
        #sleep(1)
        #GC.start(full_mark: true, immediate_sweep: true)
        #sleep(1)
      end
    end
  end
end
