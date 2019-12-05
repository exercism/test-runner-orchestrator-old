
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"
require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

container_version = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

pipeline_client = PipelineClient.new(address: "tcp://analysis-router.exercism.io:5555")

#10.times do
  run_identity = "test-#{Time.now.to_i}"
  data = pipeline_client.run_tests(:ruby, "two-fer", run_identity, s3_uri, container_version)

  puts "-------------------"
  pp data
 
  puts "-------------------"
  puts data["result"]["result"]
#end

