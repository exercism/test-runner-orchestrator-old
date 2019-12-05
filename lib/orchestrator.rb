require 'erb'
require "mandate"
require 'rbczmq'
require 'json'
require 'yaml'
require 'securerandom'
require 'concurrent-ruby'
require 'rest-client'

require "orchestrator/models/pipeline_client"
require "orchestrator/models/pipeline_client_thread_pool"
require "orchestrator/models/test_run"
require "orchestrator/models/test_runner"
require "orchestrator/models/spi"

require "orchestrator/commands/publish_message"
require "orchestrator/commands/run_tests"

module Orchestrator
  # Todo build this from JSON
  # Tracks with:
  #  - timeouts in milliseconds
  TRACKS = Concurrent::Map.new
  TRACKS[:ruby] = {timeout: 3_000}

  THREADPOOLS = Concurrent::Map.new
  TRACKS.keys.each do |track|
    THREADPOOLS[track] = PipelineClientThreadPool.new(track)
  end

  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
