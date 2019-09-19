require "mandate"
require "propono"

require "ext/propono"
require "orchestrator/publish_message"
require "orchestrator/test_submission"
require "orchestrator/listen_for_new_submissions"

module Orchestrator
  def self.listen
    ListenForNewSubmissions.()
  end
end
