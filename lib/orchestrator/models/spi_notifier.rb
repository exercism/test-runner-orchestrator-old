module Orchestrator
  class SPINotifier

    def self.notify_test_results!(submission_uuid, status, results)
      url = "#{spi_adddress}/submissions/#{submission_uuid}/test_results"
      RestClient.post(url, {
        status: status,
        results: results
      })
    end

    private

    def self.spi_adddress
      @spi_adddress ||= secrets['spi_address']
    end

    def self.secrets
      @secrets ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../../config/secrets.yml")).result)[Orchestrator.env]
    end
  end
end
