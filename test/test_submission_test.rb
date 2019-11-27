require 'test_helper'
require 'json'

module Orchestrator
  class TestSubmissionTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      track_slug = "ruby"
      exercise_slug = "two-fer"
      submission_uuid = SecureRandom.uuid
      result = {"foo" => "bar"}
      results = {"result" => {"result" => result}}
      s3_uri = "s3://test-exercism-submissions/test/testing/#{submission_uuid}"

      RestClient::Request.expects(:execute).with(
        method: :post,
        url: "http://localhost:3000/spi/submissions/#{submission_uuid}/test_results",
        payload: {
          status: :success,
          results: result
        },
        timeout: 5
      )

      test_runner = mock
      test_runner.expects(:run_tests).with(exercise_slug, s3_uri).returns(results)
      Orchestrator::TestSubmission.(test_runner, track_slug, exercise_slug, submission_uuid)
    end

    def test_calls_system_and_propono_with_the_correct_params_when_fails
      track_slug = "ruby"
      exercise_slug = "two-fer"
      submission_uuid = SecureRandom.uuid
      s3_uri = "s3://test-exercism-submissions/test/testing/#{submission_uuid}"

      propono = mock
      propono.expects(:publish).with(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :fail
      })
      Propono.expects(:configure_client).returns(propono)

      test_runner = mock
      test_runner.expects(:run_tests).with(exercise_slug, s3_uri).returns(nil)
      Orchestrator::TestSubmission.(test_runner, track_slug, exercise_slug, submission_uuid)
    end

    def test_fails_with_invalid_analyzers
      submission_uuid = SecureRandom.uuid

      propono = mock
      propono.expects(:publish).with(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :no_test_runner
      })
      Propono.expects(:configure_client).returns(propono)

      test_runner = mock
      test_runner.expects(:run_tests).never
      Orchestrator::TestSubmission.(test_runner, "foobar", "two-fer", submission_uuid)
    end
  end
end

