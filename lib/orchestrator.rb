require "mandate"
require "propono"
require "rest-client"
require 'ffi-rzmq'
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
  def self.setup_threadpools!
    languages = %w{ruby}
    @threadpools = languages.each_with_object({}) do |lang,h|
      h[lang] = TestRunnerThreadPool.new(lang)
    end
  end

  def self.threadpools
    @threadpools
  end

  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
