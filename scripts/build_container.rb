$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

client = PipelineClient.new

client.build_container("ruby", :test_runners, "039f2842cabcfdc66f7f96573144e8eb255ec6e1")
client.build_container("ruby", :test_runners, "bd8a0a593fa647c5bdd366080fc1e20c1bda7cb9")
client.build_container("ruby", :test_runners, "24431ae7048a126035210918c6987f6887d7a043")
client.build_container("ruby", :test_runners, "b6ea39ccb2dd04e0b047b25c691b17d6e6b44cfb")
