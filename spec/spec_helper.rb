require 'druid_config'
require 'webmock/rspec'

# Disable external connections
WebMock.disable_net_connect!(allow_localhost: true)

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
    # Stub DruidConfig::Client to ignore Zookeeper.
    # TODO: We must improve it!!!
    class ClientStub
      def coordinator
        'coordinator.stub/'
      end
    end
    allow(DruidConfig::Client).to receive(:new) { ClientStub.new }

    # Stub queries
    # ----------------------------------
    stub_request(:get, 'http://coordinator.stub/druid/coordinator/v1/leader')
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: 'coordinator.stub', headers: {})
  end
end
