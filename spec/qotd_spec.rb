require "spec_helper"
require "qotd/client"

def test_strategy(strategy)
  let(:client) { Qotd::Client }
  let(:linus_quotes) { Qotd::QUOTES[:linus] }
  let(:authors) { Qotd::Lookup.authors.join(",") }
  let(:version) { "QOTD SERVER VERSION #{Qotd::VERSION}" }

  config = yield(strategy, Qotd::CONFIG.dup)

  describe(strategy) do
    before(:all) do
      @server = fork do
        Qotd.start(config: config)
      end
    end

    after(:all) do
      Process.kill(:INT, @server)
    end

    it "serves quote request" do
      response = client.make_request(config: config, request:  "GET quote linus\r\n")

      expect(response.header).to eq("OK: quote linus")
      expect(linus_quotes).to include(response.body)
    end

    it "serves author requests" do
      response = client.make_request(config: config, request:  "GET authors\r\n")

      expect(response.header).to eq("OK: authors")
      expect(response.body).to eq(authors)
    end

    it "serves version requests" do
      response = client.make_request(config: config, request:  "GET version\r\n")

      expect(response.header).to eq("OK: version")
      expect(response.body).to eq(version)
    end

    it "returns an error response for invalid resource requests" do
      response = client.make_request(config: config, request:  "FLOOZ flimflam\r\n")

      expect(response.header).to eq("FAIL: INVALID REQUEST")
      expect(response.body).to be_nil
    end

    it "returns an error response for invalid resource requests" do
      response = client.make_request(config: config, request:  "GET quote johndoe\r\n")

      expect(response.header).to eq("FAIL: INVALID AUTHOR ID")
      expect(response.body).to be_nil
    end
  end
end

describe Qotd do
  test_strategy(Qotd::Strategy::Serial) do |strategy, config|
    config.tap do |config|
      config.strategy = strategy
      config.verbose  = false
      config.port     = 10017
    end
  end

  test_strategy(Qotd::Strategy::ProcessPerRequest) do |strategy, config|
    config.tap do |config|
      config.strategy = strategy
      config.verbose  = false
      config.port     = 10018
    end
  end

  test_strategy(Qotd::Strategy::ThreadPerRequest) do |strategy, config|
    config.tap do |config|
      config.strategy = strategy
      config.verbose  = false
      config.port     = 10019
    end
  end

  test_strategy(Qotd::Strategy::Prefork) do |strategy, config|
    config.tap do |config|
      config.strategy = strategy
      config.verbose  = false
      config.port     = 10020

      config.num_processes = 4
    end
  end
end
