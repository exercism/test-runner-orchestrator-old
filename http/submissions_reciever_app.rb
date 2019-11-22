require "sinatra/base"
require "sinatra/json"
require "orchestrator"

class SubmissionsReceiverApp < Sinatra::Base
  post '/submissions' do
    track_slug = params[:track_slug]
    exercise_slug = params[:exercise_slug]
    submission_uuid = params[:submission_uuid]

    # Spawn this and leave it to run.
    Thread.new do
      Orchestrator::TestSubmission.(track_slug, exercise_slug, submission_uuid)
    end

    json received: :ok
  end
end

