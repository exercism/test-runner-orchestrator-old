require 'test_helper'
require 'json'

module Orchestrator
  class TestIterationTest < Minitest::Test

    def test_calls_system_and_propono_with_the_correct_params
      Timecop.freeze do
        iteration_id = SecureRandom.uuid
        results = {"foo" => "bar"}

        s3_url = "s3://test-exercism-iterations/test/iterations/#{iteration_id}"

        data_path = File.expand_path(File.dirname(__FILE__) + "/../tmp/test_runner_runtime/ruby/runs/iteration_#{Time.now.to_i}_#{iteration_id}/iteration/")
        FileUtils.mkdir_p(data_path)
        File.open(data_path + "/results.json", "w") { |f| f << results.to_json }

        propono = mock
        propono.expects(:publish).with(:iteration_tested, {
          iteration_id: iteration_id,
          status: :success,
          results: results
        })
        Propono.expects(:configure_client).returns(propono)

        Kernel.expects(:system).with(%Q{test_iteration ruby two-fer #{s3_url} #{Time.now.to_i}_#{iteration_id}}).returns(true)
        Orchestrator::TestIteration.("ruby", "two-fer", iteration_id)
      end
    end

    def test_calls_system_and_propono_with_the_correct_params_when_fails
      Timecop.freeze do
        iteration_id = SecureRandom.uuid
        s3_url = "s3://test-exercism-iterations/test/iterations/#{iteration_id}"

        propono = mock
        propono.expects(:publish).with(:iteration_tested, {
          iteration_id: iteration_id,
          status: :fail
        })
        Propono.expects(:configure_client).returns(propono)

        Kernel.expects(:system).with(%Q{test_iteration ruby two-fer #{s3_url} #{Time.now.to_i}_#{iteration_id}}).returns(false)
        Orchestrator::TestIteration.("ruby", "two-fer", iteration_id)
      end
    end

    def test_fails_with_invalid_analyzers
      iteration_id = SecureRandom.uuid

      Kernel.expects(:system).never

      propono = mock
      propono.expects(:publish).with(:iteration_tested, {
        iteration_id: iteration_id,
        status: :no_test_runner
      })
      Propono.expects(:configure_client).returns(propono)

      Orchestrator::TestIteration.("foobar", "two-fer", iteration_id)
    end
  end
end

