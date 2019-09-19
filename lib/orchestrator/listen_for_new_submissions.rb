module Orchestrator
  class ListenForNewSubmissions
    include Mandate

    def call
      propono.listen(:new_submission) do |message|
        p "Received message"
        p message

        track_slug = message[:track_slug]
        exercise_slug = message[:exercise_slug]
        submission_id = message[:submission_id]
        TestSubmission.(track_slug, exercise_slug, submission_id)
      end
    end

    private

    memoize
    def propono
      Propono.configure_client
    end
  end
end
