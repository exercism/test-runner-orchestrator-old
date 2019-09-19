require 'test_helper'

module Orchestrator
  class ListenForNewSubmissionsTest < Minitest::Test

    def test_proxies_message_correctly
      track_slug = "ruby"
      exercise_slug = "two-fer"
      submission_id = SecureRandom.uuid
      message = {track_slug: track_slug, exercise_slug: exercise_slug, submission_id: submission_id}
      propono_client = mock
      propono_client.expects(:listen).with(:new_submission).yields(message)
      Propono.expects(:configure_client).returns(propono_client)

      TestSubmission.expects(:call).with(track_slug, exercise_slug, submission_id)
      ListenForNewSubmissions.()
    end
  end
end
