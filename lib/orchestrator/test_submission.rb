module Orchestrator

  VALID_TRACKS = %w{ruby}

  class TestSubmission
    include Mandate

    initialize_with :track_slug, :exercise_slug, :submission_id

    def call
      unless VALID_TRACKS.include?(track_slug)
        return propono.publish(:submission_tested, {
          submission_id: submission_id,
          status: :no_test_runner
        })
      end

      invoke_test_runner!

      if !test_data.empty?
        propono.publish(:submission_tested, {
          submission_id: submission_id,
          status: :success,
          results: test_data
        })
      else
        propono.publish(:submission_tested, {
          submission_id: submission_id,
          status: :fail
        })
      end
    end

    private

    memoize
    def invoke_test_runner!
      case env
      when "development"
        Bundler.with_clean_env do
          cmd = %Q{cd ../test-runner-dev-invoker && bin/run.sh #{s3_path} #{data_path}}
          p cmd
          Kernel.system(cmd)
        end
      else
        cmd = "invoke_exercism_runner #{track_slug} #{exercise_slug} #{s3_url} #{system_identifier}"
        p "Running: cmd"
        Kernel.system(cmd)
      end
    end

    memoize
    def system_identifier
      "#{Time.now.to_i}_#{submission_id}"
    end

    def s3_url
      "s3://#{s3_bucket}/#{s3_path}"
    end

    def s3_path
      "#{env}/submissions/#{submission_id}"
    end

    def env
      ENV["env"] || "development"
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
      "#{data_root_path}/#{track_slug}/runs/submission_#{system_identifier}"
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

