$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

pool = TestRunnerThreadPool.new("ruby")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
p pool.test_submission('two-fer', "fa41b291-b30e-401a-8671-fcc464dbd3d2")
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
