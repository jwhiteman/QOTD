require "spec_helper"
require "qotd/client"

def config_dummy
  Qotd::CONFIG.dup
end

describe Qotd do
  let(:client) do
    Qotd::Client
  end

  describe "serial strategy" do
    def config
      @config ||= config_dummy.tap do |config|
        config.strategy = Qotd::Strategy::Serial
        config.verbose  = false
      end
    end

    before(:all) do
      @server = fork do
        Qotd.start(config: config)
      end
    end

    after(:all) do
      Process.kill(:INT, @server)
    end

    it "serves quote request" do
      response = client.make_request(request:  "GET quote linus\r\n")

      expect(response.header).to eq("OK: quote linus")
      expect(Qotd::QUOTES[:linus]).to include(response.body)
    end

    it "serves author requests" do
      response = client.make_request(request:  "GET authors\r\n")

      expect(response.header).to eq("OK: authors")
      expect(response.body).to eq(Qotd::Lookup.authors.join(","))
    end

    it "serves version requests" do
      response = client.make_request(request:  "GET version\r\n")
      
      expect(response.header).to eq("OK: version")
      expect(response.body).to eq("QOTD SERVER VERSION 0.1.0")
    end
  end
end
