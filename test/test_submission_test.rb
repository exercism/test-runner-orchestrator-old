require 'test_helper'
require 'json'

module Orchestrator
  class TestSubmissionTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      Timecop.freeze do
        submission_id = SecureRandom.uuid
        results = {"foo" => "bar"}

        s3_url = "s3://test-exercism-submissions/test/submissions/#{submission_id}"

        data_path = File.expand_path(File.dirname(__FILE__) + "/../tmp/test_runner_runtime/ruby/runs/submission_#{Time.now.to_i}_#{submission_id}/submission/")
        FileUtils.mkdir_p(data_path)
        File.open(data_path + "/results.json", "w") { |f| f << results.to_json }

        propono = mock
        propono.expects(:publish).with(:submission_tested, {
          submission_id: submission_id,
          status: :success,
          results: results
        })
        Propono.expects(:configure_client).returns(propono)

        Kernel.expects(:system).with(%Q{test_submission ruby two-fer #{s3_url} #{Time.now.to_i}_#{submission_id}}).returns(true)
        Orchestrator::TestSubmission.("ruby", "two-fer", submission_id)
      end
    end

    def test_calls_system_and_propono_with_the_correct_params_when_fails
      Timecop.freeze do
        submission_id = SecureRandom.uuid
        s3_url = "s3://test-exercism-submissions/test/submissions/#{submission_id}"

        propono = mock
        propono.expects(:publish).with(:submission_tested, {
          submission_id: submission_id,
          status: :fail
        })
        Propono.expects(:configure_client).returns(propono)

        Kernel.expects(:system).with(%Q{test_submission ruby two-fer #{s3_url} #{Time.now.to_i}_#{submission_id}}).returns(false)
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

