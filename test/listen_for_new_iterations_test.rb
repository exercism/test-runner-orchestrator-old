require 'test_helper'

module Orchestrator
  class ListenForNewIterationsTest < Minitest::Test

    def test_proxies_message_correctly
      track_slug = "ruby"
      exercise_slug = "two-fer"
      iteration_id = SecureRandom.uuid
      message = {track_slug: track_slug, exercise_slug: exercise_slug, iteration_id: iteration_id}
      propono_client = mock
      propono_client.expects(:listen).with(:new_iteration).yields(message)
      Propono.expects(:configure_client).returns(propono_client)

      TestIteration.expects(:call).with(track_slug, exercise_slug, iteration_id)
      ListenForNewIterations.()
    end
  end
end


