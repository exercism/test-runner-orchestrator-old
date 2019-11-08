
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

require "parallel"

s3_uri = "s3://exercism-submissions/production/submissions/77/"
result = PipelineClient.run_tests("ruby", "two-fer", "test-#{Time.now.to_i}", s3_uri)


results = Parallel.map( 1...20, in_threads: 10) do |id|
  attempt = 0
  begin
    attempt += 1
    r = PipelineClient.run_tests("ruby", "two-fer", "test-#{Time.now.to_i}", s3_uri)
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
