require 'test_helper'
require 'json'

module Orchestrator
  class TestSubmissionTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      Timecop.freeze do
        track_slug = "ruby"
        exercise_slug = "two-fer"
        submission_id = SecureRandom.uuid
        results = {"foo" => "bar"}
        s3_uri = "s3://test-exercism-submissions/test/submissions/#{submission_id}"
        hex = "12345678"
        SecureRandom.expects(:hex).with(5).returns(hex)
        test_run_id = "#{Time.now.to_i}_#{submission_id}_#{hex}"

        propono = mock
        propono.expects(:publish).with(:submission_tested, {
          submission_id: submission_id,
          status: :success,
          results: results
        })
        Propono.expects(:configure_client).returns(propono)

        PipelineClient.expects(:run_tests).with(track_slug, exercise_slug, test_run_id, s3_uri).returns(results)
        Orchestrator::TestSubmission.(track_slug, exercise_slug, submission_id)
      end
    end

    def test_calls_system_and_propono_with_the_correct_params_when_fails
      Timecop.freeze do
        track_slug = "ruby"
        exercise_slug = "two-fer"
        submission_id = SecureRandom.uuid
        s3_uri = "s3://test-exercism-submissions/test/submissions/#{submission_id}"
        hex = "12345678"
        SecureRandom.expects(:hex).with(5).returns(hex)
        test_run_id = "#{Time.now.to_i}_#{submission_id}_#{hex}"

        propono = mock
        propono.expects(:publish).with(:submission_tested, {
          submission_id: submission_id,
          status: :fail
        })
        Propono.expects(:configure_client).returns(propono)

        PipelineClient.expects(:run_tests).with(track_slug, exercise_slug, test_run_id, s3_uri).returns(nil)
        Orchestrator::TestSubmission.("ruby", "two-fer", submission_id)
      end
    end

    def test_fails_with_invalid_analyzers
      submission_id = SecureRandom.uuid

      Kernel.expects(:system).never

      propono = mock
      propono.expects(:publish).with(:submission_tested, {
        submission_id: submission_id,
        status: :no_test_runner
      })
      Propono.expects(:configure_client).returns(propono)

      Orchestrator::TestSubmission.("foobar", "two-fer", submission_id)
    end
  end
end

