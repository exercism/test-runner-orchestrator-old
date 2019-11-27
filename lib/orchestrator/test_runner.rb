class TestRunner
  attr_reader :pipeline_client, :container_version, :language_slug

  BACKOFF_DELAY_SECS = 3
  MAX_RETRY_ATTEMPTS = 3

  def initialize(pipeline_client, language_slug, container_version)
    @pipeline_client = pipeline_client
    @language_slug = language_slug
    @container_version = container_version
  end

  #pipeline_client.enable_container(language_slug, :test_runners, container_version)

  def run_tests(exercise_slug, s3_uri)
    attempt = 0

    uuid = s3_uri.split('/').last.split('-').last

    begin
      attempt += 1

      puts "#{uuid}: Running #{attempt}"

      pipeline_client.run_tests(language_slug, exercise_slug, run_identity,
                                s3_uri, container_version)
=begin
    rescue ContainerTimeoutError => e
      puts "#{uuid}: Error #{e.message}"
      if attempt <= MAX_RETRY_ATTEMPTS
        puts "#{uuid}: Backoff #{attempt}"
        sleep BACKOFF_DELAY_SECS * attempt
        retry
      else
        raise
      end
    rescue ContainerWorkerUnavailableError => e
      puts "#{uuid}: Error #{e.message}"
      if attempt <= MAX_RETRY_ATTEMPTS
        puts "#{uuid}: Backoff #{attempt}"
        sleep BACKOFF_DELAY_SECS * attempt
        retry
      end
=end
    end
  end
end
