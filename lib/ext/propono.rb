require 'yaml'
require 'erb'

module Propono
  def self.configure_client
    Client.new do |config|
      creds = YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)

      creds = creds[ ENV["env"] || "development" ]

      config.access_key = creds["aws_access_key_id"]
      config.secret_key = creds["aws_secret_access_key"]
      config.queue_region = creds["aws_region"]
      config.queue_suffix = creds["aws_queue_suffix"] || ""
      config.application_name = creds["application_name"]
      # config.logger = Rails.logger
    end
  end
end
