module DruidConfig
  #
  # Class to initialize the connection to Zookeeper
  #
  class QueryBase
    # HTTParty Rocks!
    include HTTParty

    #
    # Initialize the client to perform the queris
    #
    def initialize(client)
      @client = client
      # Update the base uri to perform queries
      self.class.base_uri(
        "#{@client.coordinator}druid/coordinator/#{DruidConfig::API_VERSION}")
    end
  end
end
