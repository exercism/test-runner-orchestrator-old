
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

container_identity = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

client = PipelineClient.new
test_runner = TestRunner.new(client, "ruby", container_identity)
test_runner.ensure_container_deployed!
data = test_runner.run_tests("two-fer", s3_uri)

puts "-------------------"
puts data["result"]["result"]
