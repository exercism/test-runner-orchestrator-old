module Orchestrator
  class ListenForNewIterations
    include Mandate

    def call
      propono.listen(:new_iteration) do |message|
        p "Received message"
        p message

        track_slug = message[:track_slug]
        exercise_slug = message[:exercise_slug]
        iteration_id = message[:iteration_id]
        TestIteration.(track_slug, exercise_slug, iteration_id)
      end
    end

    private

    memoize
    def propono
      Propono.configure_client
    end
  end
end
