require 'test_helper'
require 'json'

module Orchestrator
  class RunTestsTest < Minitest::Test
    def setup
      @pipeline_client = mock
      @track_slug = :ruby
      @exercise_slug = "two-fer"
      @s3_uri = mock
      @container_version = mock
    end

    def test_works_normally
      results = {'foo' => 'bar'}
      response = JSON.parse({status: {status_code: 200}, response: results}.to_json)
      @pipeline_client.expects(:run_tests).with(@track_slug, @exercise_slug, @s3_uri, @container_version).
                       returns(response)

      test_run = RunTests.(@pipeline_client, @track_slug, @exercise_slug, @s3_uri, @container_version)
      assert test_run.ran_successfully?
      assert_equal results, test_run.results
    end

    def test_fails_correctly
      response = JSON.parse({status: {status_code: 500}}.to_json)
      @pipeline_client.expects(:run_tests).with(@track_slug, @exercise_slug, @s3_uri, @container_version).
                       returns(response)

      test_run = RunTests.(@pipeline_client, @track_slug, @exercise_slug, @s3_uri, @container_version)
      refute test_run.ran_successfully?
      assert_equal 500, test_run.status_code
    end

    def test_retries_immediately
      response = JSON.parse({status: {status_code: 512}}.to_json)
      @pipeline_client.expects(:run_tests).with(@track_slug, @exercise_slug, @s3_uri, @container_version).
                       returns(response).twice

      test_run = RunTests.(@pipeline_client, @track_slug, @exercise_slug, @s3_uri, @container_version)
      refute test_run.ran_successfully?
      assert_equal 512, test_run.status_code
    end

    def test_retries_immediately
      response = JSON.parse({status: {status_code: 503}}.to_json)
      @pipeline_client.expects(:run_tests).with(@track_slug, @exercise_slug, @s3_uri, @container_version).
                       returns(response).twice

      s = RunTests.new(@pipeline_client, @track_slug, @exercise_slug, @s3_uri, @container_version)
      s.expects(:sleep).with(5)
      test_run = s.()
      refute test_run.ran_successfully?
      assert_equal 503, test_run.status_code
    end

  end
end
