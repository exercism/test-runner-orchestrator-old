ENV["env"] = "test"

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/setup"
require "timecop"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "orchestrator"

