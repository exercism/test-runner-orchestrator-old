
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/96"

client = PipelineClient.new

# client.build_container("ruby", :static_analyzers, "v0.0.8")
# client.build_container("ruby", :static_analyzers, "v0.0.9")
#
# client.build_container("ruby", :test_runners, "039f2842cabcfdc66f7f96573144e8eb255ec6e1")
# client.build_container("ruby", :test_runners, "bd8a0a593fa647c5bdd366080fc1e20c1bda7cb9")
# client.build_container("ruby", :test_runners, "24431ae7048a126035210918c6987f6887d7a043")
# client.build_container("ruby", :test_runners, "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb")

available = client.list_available_containers("ruby", :test_runners)
puts "GOT with #{JSON.pretty_generate(available)}"

# available = client.list_available_containers("ruby", :static_analyzers)
# puts "GOT with #{JSON.pretty_generate(available)}"

current_config = client.current_config
puts "GOT with #{JSON.pretty_generate(current_config)}"

container_identity = "git-b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb"

# client.configure_containers("ruby", :test_runners, [
#   container_identity
# ])

client.deploy("ruby", :test_runners, container_identity)


data = client.run_tests("ruby", "two-fer", "test-#{Time.now.to_i}", s3_uri, container_identity)

puts "-------------------"
puts data["result"]["result"]


exit

results = Parallel.map( 1...2, in_threads: 10) do |id|
  attempt = 0
  begin
    attempt += 1
    r = client.run_tests("ruby", "two-fer", "test-#{Time.now.to_i}", s3_uri)
    { id: id, r: r }
  rescue TestRunnerTimeoutError => e
    puts e
    if attempt <= 3
      puts "backoff #{attempt}"
      sleep 3
      retry
    end
  rescue TestRunnerWorkerUnavailableError => e
    puts e
    if attempt <= 3
      puts "backoff #{attempt}"
      sleep 3
      retry
    end
  end
end


results.each do |result|
  puts "*** RESULT ******************* "
  puts result
  puts "****************************** "
end
