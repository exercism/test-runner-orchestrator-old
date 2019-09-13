require 'test_helper'

module Orchestrator
  class PublishMessageTest < Minitest::Test

    def test_publishes_to_propono
      topic = mock
      data = mock

      client = mock
      client.expects(:publish).with(topic, data, async: true)
      Propono.expects(:configure_client).returns(client)

      PublishMessage.(topic, data)
    end

    def test_publishes_to_propono_with_async_false
      topic = mock
      data = mock

      client = mock
      client.expects(:publish).with(topic, data, async: false)
      Propono.expects(:configure_client).returns(client)

      PublishMessage.(topic, data, async: false)
    end
  end
end
