require "sinatra/base"
require "sinatra/json"
require "orchestrator"

LANGUAGES = %w{ruby}
class SubmissionsReceiverApp < Sinatra::Base
  def initialize
    @threadpools = LANGUAGES.each_with_object({}) {|lang,h| h[lang] = TestRunnerThreadPool.new(lang) }
    super
  end

  post '/submissions' do
    track_slug = params[:track_slug]
    exercise_slug = params[:exercise_slug]
    submission_uuid = params[:submission_uuid]

    pool = threadpools[track_slug]
    pool.test_submission(exercise_slug, submission_uuid)

    json received: :ok
  end

  private
  attr_reader :threadpools
end

