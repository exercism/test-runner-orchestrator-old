require 'test_helper'
require 'json'

module Orchestrator
  class TestRunnerTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      track_slug = :ruby
      exercise_slug = "two-fer"
      submission_uuid = SecureRandom.uuid
      s3_uri = "s3://test-exercism-submissions/test/testing/#{submission_uuid}"

      container_version = mock
      pipeline_client = mock
      test_run = mock

      SPI.expects(:post_test_run).with(submission_uuid, test_run)
      RunTests.expects(:call).with(pipeline_client, track_slug, exercise_slug, s3_uri, container_version).returns(test_run)

      TestRunner.run(pipeline_client, container_version, track_slug, exercise_slug, submission_uuid)
    end

    def test_fails_with_invalid_analyzers
      submission_uuid = SecureRandom.uuid

      SPI.expects(:post_test_run).never

      TestRunner.run(mock, mock, "foobar", "two-fer", mock)
    end
  end
end

