require "spec_helper"
require "qotd/client"

def config_dummy
  Qotd::CONFIG.dup
end

describe Qotd do
  let(:client) { Qotd::Client }
  let(:linus_quotes) { Qotd::QUOTES[:linus] }
  let(:authors) { Qotd::Lookup.authors.join(",") }
  let(:version) { "QOTD SERVER VERSION #{Qotd::VERSION}" }

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
      expect(linus_quotes).to include(response.body)
    end

    it "serves author requests" do
      response = client.make_request(request:  "GET authors\r\n")

      expect(response.header).to eq("OK: authors")
      expect(response.body).to eq(authors)
    end

    it "serves version requests" do
      response = client.make_request(request:  "GET version\r\n")

      expect(response.header).to eq("OK: version")
      expect(response.body).to eq(version)
    end

    it "returns an error response for invalid resource requests" do
      response = client.make_request(request:  "FLOOZ flimflam\r\n")

      expect(response.header).to eq("FAIL: INVALID REQUEST")
      expect(response.body).to be_nil
    end

    it "returns an error response for invalid resource requests" do
      response = client.make_request(request:  "GET quote johndoe\r\n")

      expect(response.header).to eq("FAIL: INVALID AUTHOR ID")
      expect(response.body).to be_nil
    end
  end
end
