module DruidConfig
  #
  # Class to initialize the connection to Zookeeper
  #
  class Cluster
    # HTTParty Rocks!
    include HTTParty

    #
    # Initialize the client to perform the queris
    #
    def initialize(zk_uri, options)
      DruidConfig.client = DruidConfig::Client.new(zk_uri, options)
      # Update the base uri to perform queries
      self.class.base_uri(
        "#{DruidConfig.client.coordinator}"\
        "druid/coordinator/#{DruidConfig::API_VERSION}")
    end

    #
    # Close connection with zookeeper
    #
    def close!
      DruidConfig.client.close!
    end

    # ------------------------------------------------------------
    # Queries!
    # ------------------------------------------------------------
    
    #
    # The following methods are referenced to Druid API. To check the
    # funcionality about it, please go to Druid documentation:
    #
    # http://druid.io/docs/0.8.1/design/coordinator.html
    #

    # Coordinator
    # -----------------
    def leader
      self.class.get('/leader').body
    end

    def load_status(params = '')
      self.class.get("/loadstatus?#{params}")
    end

    def load_queue(params = '')
      self.class.get("/loadqueue?#{params}")
    end

    # Metadata
    # -----------------
    def metadata_datasources(params = '')
      self.class.get("/metadata/datasources?#{params}")
    end

    alias_method :mt_datasources, :metadata_datasources

    def metadata_datasources_segments(data_source, segment = '')
      end_point = "/metadata/datasources/#{data_source}/segments"
      if segment.empty? || segment == 'full'
        self.class.get("#{end_point}?#{params}")
      else
        self.class.get("#{end_point}/#{params}")
      end
    end

    alias_method :mt_datasources_segments, :metadata_datasources_segments

    # Data sources
    # -----------------
    def datasources
      self.class.get('/datasources?full').map do |data|
        DruidConfig::Entities::DataSource.new(data)
      end
    end

    def datasource(datasource)
      datasources.select { |el| el.name == datasource }
    end

    # Rules
    # -----------------
    def rules
      self.class.get('/rules')
    end

    # Servers
    # -----------------
    def servers(params = '')
      self.class.get("/servers?#{params}")
    end
  end
end