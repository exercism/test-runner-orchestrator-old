# This class is the threadpool used to run
# test-runners. It uses concurrent-ruby. Everything it
# executes must be threadsafe.
module Orchestrator
  class PipelineClientThreadPool
    def initialize(track_slug)
      @track_slug = track_slug
      @pipeline_clients = Concurrent::Array.new
      @threadpool = Concurrent::FixedThreadPool.new(1, max_queue: 0, idletime: 60*60)
      @pipeline_client_container = Concurrent::ThreadLocalVar.new { initialize_pipeline_client }

      #Thread.new do
      #  loop do
      #    puts "#{@threadpool.queue_length} | #{@threadpool.completed_task_count}"
      #    sleep(1)
      #  end
      #end
    end

    def test_submission(in_exercise_slug, in_uuid)
      job = Proc.new do |exercise_slug, uuid, pipeline_client_container|
        begin
          puts "#{uuid.split('-').last}: Initializing"

          #container_version = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"
          #"git-da694960c8c8d5c27c50885966a4301c050ce83a"
          container_version = TRACKS[track_slug][:container_version]
          pipeline_client = pipeline_client_container.value
          TestRunner.run(pipeline_client, container_version, track_slug, exercise_slug, uuid)
        rescue => e
          puts e
        end

=begin
        retried = false
        begin
          container_version = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"
          pipeline_client = pipeline_client_container.value
          TestRunner.run(pipeline_client, container_version, track_slug, exercise_slug, uuid)
        rescue => e
          puts "#{uuid.split('-').last}: #{e}"

          # It seems that the pipeline_client connection gets lost
          # and needs resetting. This should achieve that.
          unless retried
            puts "Trying to reset pipeline-client"
            pipeline_client_container.value = initialize_pipeline_client
            retried = true
            retry
          else
            raise
          end
        rescue => e
          puts "#{uuid.split('-').last}: #{e}"
          raise
        end
=end
      end

      threadpool.post(in_exercise_slug, in_uuid, pipeline_client_container, &job)
    end

    private
    attr_reader :track_slug, :threadpool, :pipeline_clients, :pipeline_client_container

    def initialize_pipeline_client
      PipelineClient.new.tap do |client|
        pipeline_clients.push(client)
      end
    end

    # TODO - This doesn't do anything, I presume I need to
    # call the at_exit method, not define it?
    def at_exit
      puts "Cleaning up sockets"
      pipeline_clients.each do |pc|
        client.close_socket
      end
    end
  end
end
