
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"


def get_client(language_slug, container_version)
  Thread.current[:test_runner] ||= begin
    client = PipelineClient.new
    @clients << client
    test_runner = TestRunner.new(client, language_slug)
    test_runner.select_version(container_version)
    test_runner
  end
end


s3_uri = "s3://exercism-submissions/production/submissions/96"

container_version = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

client = PipelineClient.new
test_runner = TestRunner.new(client, "ruby")
test_runner.configure_version(container_version)

@clients = []

results = Parallel.map( 1...100, in_threads: 10) do |id|
  puts "===== #{id} ========================================="
  test_runner = get_client("ruby", container_version)
  test_runner.run_tests("two-fer", s3_uri)
end

@clients.each do |client|
  client.close_socket
end

results.each do |result|
  puts "*** RESULT ******************* "
  puts result
  puts "****************************** "
end
