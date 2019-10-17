require "mandate"
require "propono"

require "ext/propono"
require "orchestrator/pipeline_client"
require "orchestrator/publish_message"
require "orchestrator/test_submission"
require "orchestrator/listen_for_new_submissions"

class TestRunnerError < RuntimeError
end

class TestRunnerTimeoutError < TestRunnerError
end

class TestRunnerWorkerUnavailableError < TestRunnerError
end

module Orchestrator
  def self.listen
    ListenForNewSubmissions.()
  end
end
