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
  #  - container versions set to whatever is currently deployed
  TRACKS = Concurrent::Map.new
  TRACKS[:csharp] = {timeout: 10_000, container_version: "git-c555b7195e75c2a93eafd71d86afb9b5dfb2a5b6"}
  TRACKS[:elixir] = {timeout: 10_000, container_version: "git-a8c7b8e5c1881792c4169e816c7b737b2ba7305c"}
  TRACKS[:python] = {timeout: 10_000, container_version: "git-777031cbe192bbc567fd5b5253db4b0545621e6c"}
  TRACKS[:ruby]   = {timeout: 3_000,  container_version: "git-548a78c2c932408f9ede63589f3e77f4aeb60586"}
  TRACKS[:rust]   = {timeout: 10_000, container_version: "git-91aca5f26365595d76bf60b114a6eeefc3d416a5"}
  TRACKS[:javascript] = {timeout: 10_000, container_version: "git-d5402c2f9e1d4b01517675680fa21201c9344f91"}

  # A threadpool per track
  THREADPOOLS = Concurrent::Map.new
  TRACKS.keys.each do |track|
    THREADPOOLS[track] = PipelineClientThreadPool.new(track)
  end

  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
