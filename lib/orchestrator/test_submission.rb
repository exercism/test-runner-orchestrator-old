module Orchestrator

  VALID_TRACKS = %w{ruby}

  class TestSubmission
    include Mandate

    initialize_with :test_runner, :track_slug, :exercise_slug, :submission_uuid

    def call
      unless VALID_TRACKS.include?(track_slug)
        return propono.publish(:submission_tested, {
          submission_uuid: submission_uuid,
          status: :no_test_runner
        })
      end

      test_data = invoke_test_runner!

      if test_data && !test_data.empty?
        path = "http://localhost:3000/spi/submissions/#{submission_uuid}/test_results"
        RestClient.post(path, {
          status: :success,
          results: test_data
        })
      else
        propono.publish(:submission_tested, {
          submission_uuid: submission_uuid,
          status: :fail
        })
      end
    end

    private

    memoize
    def invoke_test_runner!
      data = test_runner.run_tests(exercise_slug, s3_uri)
      res = data&.fetch("result")&.fetch("result")
      puts "#{submission_uuid.split('-').last}: Results #{res}"
      res
    end

    def s3_uri
      creds = YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[Orchestrator.env]
      bucket = creds['aws_submissions_bucket']
      path = "#{Orchestrator.env}/testing/#{submission_uuid}"

      "s3://#{bucket}/#{path}"
    end

    memoize
    def propono
      Propono.configure_client
    end
  end
end
