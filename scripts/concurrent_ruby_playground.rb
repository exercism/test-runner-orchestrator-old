$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

pool = TestRunnerThreadPool.new("ruby")
ids = ["03b5d611-bf1a-45cb-8204-9729f86067db", "23edbc14-832d-4eb9-bfee-04732f380d4b", "023c03b6-2ea7-42d5-bf16-a75c8f027363", "27a796b6-b302-4066-92c5-754e14f0c654", "d8209c86-15d1-4dd2-a52a-4e961aefafcf", "1e7408a0-6984-43ab-b5fc-a017f005b222", "7532aaa5-bb60-4339-a3f5-3a6e7ca6d4c8", "704fa1e0-8fbf-4ae3-b060-a66ae8f8e96f", "10245843-d9b7-48d7-a911-c5fe7e0c8507", "57b9a882-2c69-4aaa-881d-52c311b4f408", "8f2d65ba-0984-404c-95cd-b5b74be93d1e", "dfdea15c-dc26-4d15-921f-6d9480b9534a", "8aea6727-ba96-4d1e-b22b-3d0bed4ffd50", "5df477bc-c4cd-4de1-80b9-13d6d5dae97f", "31741eee-8c11-4424-b661-6e32cc76f01d", "9b6d0ded-ab6f-4a90-a669-90d74a9a1a9c", "a38ca2ba-207e-499f-bec5-b1bc0250efaf", "08884216-f8a2-42f4-bf7d-45566bca1953", "c2523eb2-428c-4786-be66-fea49eb7646c", "8e83f1cd-3caa-4d60-9295-8befdb406ea6", "530586dd-03fc-4670-8db0-1c260edbaf60", "4e4218ce-cde0-4a82-9ade-c1803dd73a79", "7c86429f-5eff-4ce9-b2ea-438b27de2d8a", "0eaaf073-60bd-4f77-b902-d32ac195e033", "00226ec4-30e8-4438-82ab-c0db7efa2015", "b5177579-a280-4206-ae7a-bd13140b353b", "48e294da-ae3e-4e4e-ad41-c36486b9b9b7", "f669f40e-f80a-4586-833c-3e9e9fc0b16d", "8a9aa1ba-b8d3-4a29-b4c7-e5354b72fb39", "c8ef1e6a-43cd-4743-ab9c-639e1b141b6a"] 
ids.each do |id|
  #p pool.test_submission('two-fer', id)
  #ids[0,10].each do |id|
  RestClient.post('http://localhost:9292/submissions', {track_slug: "ruby", exercise_slug: "two-fer", submission_uuid: id})
  sleep(0.2)
end
sleep(100)

=begin
20.times do
  pool << Proc.new do
    sleep(rand(5000) / 1000.0)
    p "==="
    p Thread.current
    p Thread.current["foobar"]
    Thread.current["foobar"] = "barfoo" unless Thread.current["foobar"]
    Thread.current[:test_runner] ||= begin
      client = PipelineClient.new(address: "tcp://analysis-router.exercism.io:5555")
      @clients << client
      test_runner = TestRunner.new(client, language_slug)
      test_runner.select_version(container_version)
      test_runner
    end
  end
end

sleep(100)
=end
