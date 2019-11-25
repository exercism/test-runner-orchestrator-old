class TestRunner
  attr_reader :pipeline_client, :latest_version, :language_slug

  def initialize(pipeline_client, language_slug)
    @pipeline_client = pipeline_client
    @language_slug = language_slug
    @backoff_delay_seconds = 3
    @max_retry_attempts = 3
  end

  def configure_version(latest_version)
    select_version(latest_version)
    pipeline_client.enable_container(language_slug, :test_runners, latest_version)
  end

  def select_version(latest_version)
    @latest_version = latest_version
  end

  def run_tests(exercise_slug, s3_uri)
    attempt = 0
    begin
      attempt += 1
      run_identity = "test-#{Time.now.to_i}"
      result = pipeline_client.run_tests(language_slug, exercise_slug, run_identity,
                                      s3_uri, latest_version)
      return result
    rescue ContainerTimeoutError => e
      puts e
      if attempt <= @max_retry_attempts
        puts "backoff #{attempt}"
        sleep @backoff_delay_seconds * attempt
        retry
      end
    rescue ContainerWorkerUnavailableError => e
      puts e
      if attempt <= @max_retry_attempts
        puts "backoff #{attempt}"
        sleep @backoff_delay_seconds * attempt
        retry
      end
    end
  end
end
