require 'druid_config'
require 'webmock/rspec'

# Mock Druid
ENV['MOCK_DRUID'] ||= 'false'

if ENV['MOCK_DRUID'] == 'true'
  # Disable external connections
  WebMock.disable_net_connect!(allow_localhost: true)
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Use color in STDOUT
  config.color = true
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true
  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  #
  # Mock druid API queries
  #
  config.before(:each) do
    if ENV['MOCK_DRUID'] == 'true'
      # Stub DruidConfig::Client to ignore Zookeeper.
      # TODO: We must improve it!!!
      class ClientStub
        def coordinator
          'coordinator.stub/'
        end
      end
      allow(DruidConfig).to receive(:client) { ClientStub.new }

      # Stub queries
      # ----------------------------------
      
      # Our scenario:
      # leader: coordinator.stub
      # datasources: datasource1, datasource2
      # tiers: _default_tier, hot
      # stub_request(:get, 'http://coordinator.stub/druid/coordinator/v1/leader')
      #   .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      #   .to_return(status: 200, body: 'coordinator.stub', headers: {})

      # stub_request(:get, 'http://coordinator.stub/druid/coordinator/v1/loadstatus')
      #   .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      #   .to_return(status: 200, body: '{"datasource1":100.0,"datasource2":100.0}',
      #              headers: { 'Content-Type' => 'application/json' })

      # stub_request(:get, 'http://coordinator.stub/druid/coordinator/v1/loadstatus?simple')
      #   .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      #   .to_return(status: 200, body: '{"datasource1":0,"datasource2":0}',
      #              headers: { 'Content-Type' => 'application/json' })

      # stub_request(:get, 'http://coordinator.stub/druid/coordinator/v1/loadstatus?full')
      #   .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      #   .to_return(status: 200, body: '{"_default_tier":{"datasource1":0}, "hot":{"datasource2":0}}',
      #              headers: { 'Content-Type' => 'application/json' })
    end
  end
end
