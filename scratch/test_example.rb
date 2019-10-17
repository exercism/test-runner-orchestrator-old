#!/usr/bin/env ruby

require_relative "./pipeline_client"

pipeline = PipelineClient.new

puts "Sample for ruby:two-fer"

lang = "ruby"
exercise_slug = "two-fer"
solution_slug = "soln-demo" # ideally this would be unique-ish
source = "s3://exercism-iterations/production/iterations/1182520"

response = pipeline.test_run(lang, exercise_slug, solution_slug, source)
pipeline.close_socket

puts " === Complete ==="
puts response.keys

if response["logs"]
  response["logs"].each do |log_line|
    puts "+ #{log_line["cmd"]}"
    puts log_line["stdout"]
    puts log_line["stderr"]
  end
end

puts response["result"]
