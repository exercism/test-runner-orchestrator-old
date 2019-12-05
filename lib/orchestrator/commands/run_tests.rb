class RunTests
  include Mandate

  MAX_ATTEMPTS = 2
  BACKOFF_SECS = 5

  def initialize(pipeline_client, track_slug, exercise_slug, s3_uri, container_version)
    @pipeline_client = pipeline_client
    @track_slug = track_slug
    @exercise_slug = exercise_slug
    @s3_uri = s3_uri
    @container_version = container_version
  end

  def call
    attempts = 0

    loop do
      attempts += 1

      data = pipeline_client.run_tests(track_slug, exercise_slug,
                                       s3_uri, container_version)

      test_run = TestRun.new(data)

      # If we're good, return the test run.
      return test_run if test_run.ran_successfully?

      # If there's no status or something else weird has happened, 
      # then return the test run and get out of here
      return test_run if test_run.catastrophic_error?

      # If we are out of attempts then return the failed test run
      return test_run if attempts >= MAX_ATTEMPTS

      # Retry immediately if we should do so
      redo if test_run.should_immediately_retry?

      # Backoff and retry if we should wait a bit.
      if test_run.should_backoff_and_retry?
        sleep(BACKOFF_SECS)
        redo
      end

      # If we shouldn't retry, then we can just pass back the
      # test_run, and it will have a failure message>
      # This needs to be an explict retry as we're in a loop here.
      return test_run
    end
  end

  private
  attr_reader :pipeline_client, :track_slug, :exercise_slug, :s3_uri, :container_version
end
