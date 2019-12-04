=begin
def run_tests(exercise_slug, s3_uri)
  attempt = 0

  begin
    attempt += 1

    puts "#{uuid}: Running #{attempt}"

    DO STUFF

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
  end
end
=end
