$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"
require "orchestrator"

class SubmissionsReceiverApp < Sinatra::Base
  post '/submissions' do
    track_slug = params[:track_slug].to_sym
    exercise_slug = params[:exercise_slug].to_sym
    submission_uuid = params[:submission_uuid]

    puts "Queuing #{submission_uuid.split("-").last}: #{submission_uuid}"
    pool = Orchestrator::THREADPOOLS[track_slug]
    pool.test_submission(exercise_slug, submission_uuid)

    json received: :ok
  end
end
