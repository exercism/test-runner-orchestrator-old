#!/usr/bin/env ruby

# require "bundler/setup"
# $LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# require "orchestrator"
# Orchestrator.listen

$stdout.sync = true
$stderr.sync = true

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require_relative "http/submissions_reciever_app"

run SubmissionsReceiverApp
