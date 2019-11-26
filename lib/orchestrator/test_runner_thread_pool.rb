# This class is the threadpool used to run
# test-runners. It uses concurrent-ruby. Everything it
# executes must be threadsafe.
class TestRunnerThreadPool
  def initialize(track_slug)
    @track_slug = track_slug
    #@pipeline_clients = Concurrent::Array.new
    @threadpool = Concurrent::FixedThreadPool.new(1, max_queue: 0, idletime: 60*60)
    @test_runner_container = Concurrent::ThreadLocalVar.new { initialize_test_runner }

    Thread.new do
      loop do
        puts "#{@threadpool.queue_length} | #{@threadpool.completed_task_count}"
        sleep(1)
      end
    end
  end

  def test_submission(exercise_slug, uuid)
    threadpool.post do
      puts "#{uuid.split('-').last}: Initializing"
      retried = false
      begin
        Orchestrator::TestSubmission.(test_runner_container.value, track_slug, exercise_slug, uuid)
      rescue => e
        puts e
        # It seems that the test-runner connection gets lost
        # and needs resetting. This should achieve that.
        unless retried
          puts "Trying to reset test-runner"
          test_runner_container.value = initialize_test_runner
          retried = true
          retry
        end
      end
    end
  end

  private
  attr_reader :track_slug, :threadpool, :pipeline_clients, :test_runner_container

  def initialize_test_runner
    client = initialize_pipeline_client
    test_runner = TestRunner.new(client, track_slug)
    test_runner.select_version("git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb")
    test_runner
  end

  def initialize_pipeline_client
    address = "tcp://analysis-router.exercism.io:5555"#?topic=#{track_slug}"
    PipelineClient.new(address: address)#.tap do |client|
    #  pipeline_clients.push(client)
    #end
  end
end
