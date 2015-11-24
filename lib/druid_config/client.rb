module DruidConfig
  #
  # Class to initialize the connection to Zookeeper
  #
  class Client
    attr_reader :zk, :zookeeper, :opts

    #
    # Initialize Zookeeper connection
    #
    def initialize(zookeeper, opts = {})
      # Store it for future resets
      @zookeeper = zookeeper
      @opts = opts
      @zk = ZK.new(zookeeper, opts)
    end

    #
    # Get the URL of a coordinator.
    #
    # This funciton can raise a DruidConfig::Exceptions::NotAvailableNodes
    # exception indicating there aren't any node to process this request
    #
    def coordinator
      return zk.coordinator if zk.coordinator
      fail DruidConfig::Exceptions::NotAvailableNodes, 'coordinator'
    end

    #
    # Get the URI of a overlord
    #
    # This funciton can raise a DruidConfig::Exceptions::NotAvailableNodes
    # exception indicating there aren't any node to process this request
    #
    def overlord
      return zk.overlord if zk.overlord
      fail DruidConfig::Exceptions::NotAvailableNodes, 'overlord'
    end

    #
    # Close the client
    #
    def close!
      zk.close!
    end

    #
    # Reset the client
    #
    def reset!
      close!
      @zk = ZK.new(@zookeeper, @opts)
    end
  end
end
