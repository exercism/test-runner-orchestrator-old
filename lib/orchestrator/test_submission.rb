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
      case env
      when "development"
        #invoke_development_test_runner!
        invoke_production_test_runner!
      else
        invoke_production_test_runner!
      end
    end

    def invoke_development_test_runner!
      PipelineClient.run_tests(track_slug, exercise_slug, test_run_id, s3_uri)

      #Bundler.with_clean_env do
      #  cmd = %Q{cd ../test-runner-dev-invoker && bin/run.sh #{s3_path} #{data_path}}
      #  p cmd
      #  Kernel.system(cmd)
      #end
    end

    def invoke_production_test_runner!
      data = test_runner.run_tests(exercise_slug, s3_uri)
      res = data["result"]["result"]
      puts res
      res
    end

    memoize
    def test_run_id
      "#{Time.now.to_i}_#{submission_uuid}_#{SecureRandom.hex(5)}"
    end

    def s3_uri
      "s3://#{s3_bucket}/#{s3_path}"
    end

    def s3_path
      "#{env}/testing/#{submission_uuid}"
    end

    def env
      ENV["ENV"] || "development"
    end

    def s3_bucket
      creds = YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[env]
      creds['aws_submissions_bucket']
    end

    def test_data
      # "iteration" here is temporary
      location = "#{data_path}/iteration/output/results.json"
      JSON.parse(File.read(location))
    rescue
      {}
    end

    def data_path
      "#{data_root_path}/#{track_slug}/runs/submission_#{test_run_id}"
    end

    def data_root_path
      case env
      when "production"
        PRODUCTION_DATA_PATH
      else
        File.expand_path(File.dirname(__FILE__) + "/../../tmp/test_runner_runtime/").tap do |path|
          FileUtils.mkdir_p(path)
        end
      end
    end

    memoize
    def propono
      Propono.configure_client
    end

    PRODUCTION_DATA_PATH = "/opt/exercism/test_runner_runtime".freeze
    private_constant :PRODUCTION_DATA_PATH
  end
end

