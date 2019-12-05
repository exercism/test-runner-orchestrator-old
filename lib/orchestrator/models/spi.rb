module Orchestrator
  class SPI

    def self.post_test_run(submission_uuid, test_run)
      url = "#{spi_adddress}/submissions/#{submission_uuid}/test_results"
      RestClient.post(url, {
        ops_status: test_run.status,
        ops_message: test_run.message,
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
