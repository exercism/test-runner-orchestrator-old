module Orchestrator
  class TestSubmission
    include Mandate

    initialize_with :pipeline_client, :container_version, :track_slug, :exercise_slug, :submission_uuid

    def call
      return if abort_on_invalid_track!

      run_tests!

      if test_results && !test_results.empty?
        handle_success!
      else
        handle_error!
      end
    end

    private
    attr_accessor :test_results

    def abort_on_invalid_track!
      return false if Orchestrator::TRACKS.keys.include?(track_slug)

      propono.publish(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :no_test_runner
      })
      true
    end

    def run_tests!
      run_identity = "test-#{Time.now.to_i}"
      data = pipeline_client.run_tests(track_slug, exercise_slug, run_identity,
                                       s3_uri, container_version)

      self.test_results = data&.fetch("result")&.fetch("result")
      puts "#{submission_uuid.split('-').last}: Results #{test_results}"
    end

    def handle_success!
      spi_adddress = secrets['spi_adddres']
      url = "#{spi_adddress}/submissions/#{submission_uuid}/test_results"
      RestClient.post(url, {
        status: :success,
        results: test_results
      })
    rescue => e
      puts e
    end

    def handle_error!
      propono.publish(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :fail
      })
    end

    def s3_uri
      bucket = secrets['aws_submissions_bucket']
      path = "#{Orchestrator.env}/testing/#{submission_uuid}"

      "s3://#{bucket}/#{path}"
    end
    
    memoize
    def secrets
      YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[Orchestrator.env]
    end

    memoize
    def propono
      Propono.configure_client
    end
  end
end
