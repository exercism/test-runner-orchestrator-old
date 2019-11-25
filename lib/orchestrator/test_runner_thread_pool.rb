# This class is the threadpool used to run
# test-runners. It uses concurrent-ruby. Everything it
# executes must be threadsafe.
class TestRunnerThreadPool
  def initialize(track_slug)
    @track_slug = track_slug
    @pipeline_clients = Concurrent::Array.new
    @threadpool = Concurrent::FixedThreadPool.new(5)
  end

  def test_submission(exercise_slug, uuid)
    threadpool.post do
      retried = false
      begin
        Orchestrator::TestSubmission.(thread_test_runner, track_slug, exercise_slug, uuid)
      rescue
        unless retried
          p "Resetting test-runner"
          set_thread_test_runner
          retried = true
          retry
        end
      end
    end
  end

  private
  attr_reader :track_slug, :threadpool, :pipeline_clients

  def thread_test_runner
    Thread.current[:test_runner] || set_thread_test_runner
  end

  def set_thread_test_runner
    Thread.current[:test_runner] = initialize_test_runner
  end

  def initialize_test_runner
    client = initialize_pipeline_client
    test_runner = TestRunner.new(client, track_slug)
    test_runner.select_version("git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb")
    test_runner
  end

  def initialize_pipeline_client
    address = "tcp://analysis-router.exercism.io:5555"#?topic=#{track_slug}"
    PipelineClient.new(address: address).tap do |client|
      pipeline_clients.push(client)
    end
  end
end
