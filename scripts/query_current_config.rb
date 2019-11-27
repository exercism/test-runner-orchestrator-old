
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

client = PipelineClient.new

available = client.list_available_containers("ruby", :test_runners)
puts "GOT with #{JSON.pretty_generate(available)}"

current_config = client.current_config
puts "GOT with #{JSON.pretty_generate(current_config)}"
