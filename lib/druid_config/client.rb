module DruidConfig
  #
  # Class to initialize the connection to Zookeeper
  #
  class Client
    attr_reader :zk

    #
    # Initialize Zookeeper connection
    #
    def initialize(zookeeper, opts = {})
      @zk = ZK.new(zookeeper, opts)
    end

    #
    # Get the URL of a coordinator
    #
    def coordinator
      zk.coordinator
    end
  end
end
