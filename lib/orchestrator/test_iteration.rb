module Orchestrator

  VALID_TRACKS = %w{ruby}

  class TestIteration
    include Mandate

    initialize_with :track_slug, :exercise_slug, :iteration_id

    def call
      unless VALID_TRACKS.include?(track_slug)
        return propono.publish(:iteration_tested, {
          iteration_id: iteration_id,
          status: :no_test_runner
        })
      end

      cmd = %Q{test_iteration #{track_slug} #{exercise_slug} #{s3_url} #{system_identifier}}
      p "Running #{cmd}"

      if Kernel.system(cmd)
        propono.publish(:iteration_tested, {
          iteration_id: iteration_id,
          status: :success,
          results: test_data
        })
      else
        propono.publish( :iteration_tested, {
          iteration_id: iteration_id,
          status: :fail
        })
      end
    end

    private

    memoize
    def system_identifier
      "#{Time.now.to_i}_#{iteration_id}"
    end

    def s3_url
      "s3://#{s3_bucket}/#{env}/iterations/#{iteration_id}"
    end

    def env
      ENV["env"] || "development"
    end

    def s3_bucket
      creds = YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[env]
      creds['aws_iterations_bucket']
    end

    def test_data
      location = "#{data_root_path}/#{track_slug}/runs/iteration_#{system_identifier}/iteration/report.json"
      JSON.parse(File.read(location))
    rescue
      {}
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

