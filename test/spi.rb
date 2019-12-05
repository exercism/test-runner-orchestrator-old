require 'test_helper'
require 'json'

module Orchestrator
  class SPITest < Minitest::Test

    def test_calls_rest_client
      status_code = 300
      status_message = "Something happened"
      results = {"foo" => "bar"}
      submission_uuid = SecureRandom.uuid

      test_run = TestRun.new({
        "status" => {
          "status_code" => status_code
          "message" => status_message
          "results" => results
        }
      })
      RestClient.expects(:post).with(
        "http://test-host.exercism.io/submissions/#{submission_uuid}/test_results",
        {
          ops_status: status_code,
          ops_message: status_message,
          results: results
        }
      )
      SPI.post_test_run(submission_uuid, test_run)
    end
  end
end
