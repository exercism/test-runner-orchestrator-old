require 'test_helper'
require 'json'

module Orchestrator
  class TestSubmissionTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      Timecop.freeze do
        track_slug = :ruby
        exercise_slug = "two-fer"
        submission_uuid = SecureRandom.uuid
        result = {"foo" => "bar"}
        results = {"result" => {"result" => result}}
        s3_uri = "s3://test-exercism-submissions/test/testing/#{submission_uuid}"

        RestClient.expects(:post).with(
          "http://test-host.exercism.io/submissions/#{submission_uuid}/test_results",
          {
            status: :success,
            results: result
          }
        )

        container_version = mock
        pipeline_client = mock
        pipeline_client.expects(:run_tests).with(track_slug, exercise_slug, "test-#{Time.now.to_i}", s3_uri, container_version).returns(results)
        Orchestrator::TestSubmission.(pipeline_client, container_version, track_slug, exercise_slug, submission_uuid)
      end
    end

    def test_calls_system_and_propono_with_the_correct_params_when_fails
      Timecop.freeze do
        track_slug = :ruby
        exercise_slug = "two-fer"
        submission_uuid = SecureRandom.uuid
        s3_uri = "s3://test-exercism-submissions/test/testing/#{submission_uuid}"

        propono = mock
        propono.expects(:publish).with(:submission_tested, {
          submission_uuid: submission_uuid,
          status: :fail
        })
        Propono.expects(:configure_client).returns(propono)

        container_version = mock
        pipeline_client = mock
        pipeline_client.expects(:run_tests).with(track_slug, exercise_slug, "test-#{Time.now.to_i}", s3_uri, container_version).returns(nil)
        Orchestrator::TestSubmission.(pipeline_client, container_version, track_slug, exercise_slug, submission_uuid)
      end
    end

    def test_fails_with_invalid_analyzers
      submission_uuid = SecureRandom.uuid

      propono = mock
      propono.expects(:publish).with(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :no_test_runner
      })
      Propono.expects(:configure_client).returns(propono)

      container_version = mock
      pipeline_client = mock
      pipeline_client.expects(:run_tests).never
      Orchestrator::TestSubmission.(pipeline_client, container_version, "foobar", "two-fer", submission_uuid)
    end
  end
end

