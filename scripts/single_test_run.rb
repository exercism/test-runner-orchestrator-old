
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"
require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

container_version = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

client = PipelineClient.new(address: "tcp://analysis-router.exercism.io:5555")
test_runner = TestRunner.new(client, "ruby")
test_runner.configure_version(container_version)

#10.times do
  data = test_runner.run_tests("two-fer", s3_uri)
  puts "-------------------"
  puts data["result"]["result"]
#end

