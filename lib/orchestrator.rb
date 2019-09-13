require "mandate"
require "propono"

require "ext/propono"
require "orchestrator/test_iteration"
require "orchestrator/publish_message"
require "orchestrator/listen_for_new_iterations"

module Orchestrator
  def self.listen
    ListenForNewIterations.()
  end
end
