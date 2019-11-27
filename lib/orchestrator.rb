require "mandate"
require "propono"
require 'rbczmq'
require 'json'
require 'yaml'
require 'securerandom'
require 'concurrent-ruby'
require 'rest-client'

require "ext/propono"
require "orchestrator/exceptions"
require "orchestrator/pipeline_client"
require "orchestrator/test_runner"
require "orchestrator/test_runner_thread_pool"
require "orchestrator/publish_message"
require "orchestrator/test_submission"

module Orchestrator
  # Todo build this from JSON
  # Tracks with:
  #  - timeouts in milliseconds
  TRACKS = Concurrent::Map.new
  TRACKS[:ruby] = Concurrent::Map.new
  TRACKS[:ruby][:timeout] = 3_000

  THREADPOOLS = Concurrent::Map.new
  TRACKS.keys.each do |track|
    THREADPOOLS[track] = TestRunnerThreadPool.new(track)
  end

  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
