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
      @zookeeper = :zk
      @opts = opts
      @zk = ZK.new(zookeeper, opts)
    end

    #
    # Get the URL of a coordinator
    #
    def coordinator
      zk.coordinator
    end

    #
    # Get the URI of a overlord
    #
    def overlord
      zk.overlord
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
