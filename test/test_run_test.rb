require 'test_helper'

module Orchestrator
  class TestRunTest < Minitest::Test
    def test_catastrophic_error
      assert TestRun.new({}).catastrophic_error?
      assert TestRun.new({'status' => {'status_code' => "abc"}}).catastrophic_error?
      assert TestRun.new({'status' => {'status_code' => 100}}).catastrophic_error?

      refute TestRun.new({'status' => {'status_code' => 500}}).catastrophic_error?
    end

    def test_ran_successfully
      assert TestRun.new({'status' => {'status_code' => 200}}).ran_successfully?

      refute TestRun.new({}).ran_successfully?
      refute TestRun.new({'status' => {'status_code' => 500}}).ran_successfully?
    end

    def test_should_immediately_retry
      TestRun::IMMEDIATE_RETRYABLE_ERRORS.each do |code|
        assert TestRun.new({'status' => {'status_code' => code}}).should_immediately_retry?
      end
      refute TestRun.new({'status' => {'status_code' => 200}}).should_immediately_retry?
    end

    def test_should_backoff_and_retry
      TestRun::BACKOFF_RETRYABLE_ERRORS.each do |code|
        assert TestRun.new({'status' => {'status_code' => code}}).should_backoff_and_retry?
      end
      refute TestRun.new({'status' => {'status_code' => 200}}).should_backoff_and_retry?
    end

  end
end
