
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

container_identity = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

client = PipelineClient.new
test_runner = TestRunner.new(client, "ruby", container_identity)
test_runner.ensure_container_deployed!

clients = []

results = Parallel.map( 1...100, in_threads: 10) do |id|
  puts "===== #{id} ========================================="
  client = (Thread.current[:pipeline_client] ||= PipelineClient.new)
  clients << client
  test_runner = (Thread.current[:test_runner] ||= TestRunner.new(client, "ruby", container_identity))
  test_runner.run_tests("two-fer", s3_uri)
end

clients.each do |client|
  client.close_socket
end

results.each do |result|
  puts "*** RESULT ******************* "
  puts result
  puts "****************************** "
end
