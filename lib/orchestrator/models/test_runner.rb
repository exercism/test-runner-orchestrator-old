module Orchestrator
  class TestRunner

    def self.run(*args)
      new(*args).run
    end

    def initialize(pipeline_client, container_version, track_slug, exercise_slug, submission_uuid)
      @pipeline_client = pipeline_client
      @container_version = container_version
      @track_slug = track_slug
      @exercise_slug = exercise_slug
      @submission_uuid = submission_uuid
    end

    def run
      return if abort_on_invalid_track!

      run_tests!

      if test_run.ran_successfully?
        handle_success!
      else
        handle_error!
      end
    end

    private
    attr_reader :pipeline_client, :container_version, :track_slug, :exercise_slug, :submission_uuid
    attr_accessor :test_run

    def abort_on_invalid_track!
      return false if Orchestrator::TRACKS.keys.include?(track_slug)

      propono.publish(:submission_tested, {
        submission_uuid: submission_uuid,
        status: :no_test_runner
      })
      true
    end

    def run_tests!
      self.test_run = RunTests.(pipeline_client, track_slug, exercise_slug, s3_uri, container_version)
      puts "#{submission_uuid.split('-').last}: Results #{test_run.results}"
    end

    def handle_success!
      SPINotifier.notify_test_results!(submission_uuid, :success, test_run.results)
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

    def secrets
      @secrets ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../../config/secrets.yml")).result)[Orchestrator.env]
    end

    def propono
      @propono ||= Propono.configure_client
    end
  end
end
