
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

container_version = "UNKNOWN"

client = PipelineClient.new
test_runner = TestRunner.new(client, "ruby")
test_runner.select_version(container_version)
data = test_runner.run_tests("two-fer", s3_uri)

puts "-------------------"
puts data
