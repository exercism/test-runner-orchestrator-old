STDOUT.sync = true
STDERR.sync = true

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
require "orchestrator/pipeline_client"
require "orchestrator/test_runner"
require "orchestrator/test_runner_thread_pool"
require "orchestrator/publish_message"
require "orchestrator/test_submission"

class TestRunnerError < RuntimeError
end

class TestRunnerTimeoutError < TestRunnerError
end

class TestRunnerWorkerUnavailableError < TestRunnerError
end

module Orchestrator
  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
