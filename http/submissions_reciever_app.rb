require "sinatra/base"
require "sinatra/json"
require "orchestrator"

Orchestrator.setup!

class SubmissionsReceiverApp < Sinatra::Base
  def initialize(*args)
    super(*args)
  end

  post '/submissions' do
    track_slug = params[:track_slug]
    exercise_slug = params[:exercise_slug]
    submission_uuid = params[:submission_uuid]

    puts "Queuing #{submission_uuid.split("-").last}: #{submission_uuid}"
    pool = Orchestrator.threadpools[track_slug]
    pool.test_submission(exercise_slug, submission_uuid)

    json received: :ok
  end
end
