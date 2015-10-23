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
        "druid/coordinator/#{DruidConfig::Version::API_VERSION}")
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
      datasource_status = load_status
      self.class.get('/datasources?full').map do |data|
        DruidConfig::Entities::DataSource.new(
          data,
          datasource_status.select { |k, _| k == data['name'] }.values.first)
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

    # Tiers
    # -----------------
    def tiers
      current_nodes = servers
      # Initialize tiers
      current_nodes.map(&:tier).uniq.map do |tier|
        DruidConfig::Entities::Tier.new(
          tier,
          current_nodes.select { |node| node.tier == tier })
      end
    end

    # Servers
    # -----------------
    def servers
      queue = load_queue('full')
      self.class.get('/servers?full').map do |data|
        DruidConfig::Entities::Node.new(
          data,
          queue.select { |k, _| k == data['host'] }.values.first)
      end
    end

    def physical_servers
      @physical_servers ||= servers.map(&:host).uniq
    end

    alias_method :nodes, :servers
    alias_method :physical_nodes, :physical_servers

    #
    # Returns only historial nodes
    #
    def historicals
      servers.select { |node| node.type == :historical }
    end

    #
    # Returns only realtime
    #
    def realtimes
      servers.select { |node| node.type == :realtime }
    end

    # workers
    def workers
      # Stash the base_uri
      stash_uri
      self.class.base_uri(
        "#{DruidConfig.client.overlord}"\
        "druid/indexer/#{DruidConfig::Version::API_VERSION}")
      # Perform a query
      workers = self.class.get('/workers').map do |worker|
        DruidConfig::Entities::Worker.new(worker)
      end
      # Recover it
      pop_uri
      # Return
      workers
    end

    def physical_workers
      @physical_workers ||= workers.map(&:host).uniq
    end

    # Services
    # -----------------
    
    def services
      return @services if @services
      services = {}
      physical_nodes.each { |node| services[node] = [] }
      # Load services
      realtimes.map(&:host).uniq.each { |r| services[r] << :realtime }
      historicals.map(&:host).uniq.each { |r| services[r] << :historical }
      physical_workers.each { |w| services[w] << :middleManager }
      # Return nodes
      @services = services
    end

    private

    #
    # Stash current base_uri
    #
    def stash_uri
      @uri_stack ||= []
      @uri_stack.push self.class.base_uri
    end

    #
    # Pop next base_uri
    #
    def pop_uri
      return if @uri_stack.nil? || @uri_stack.empty?
      self.class.base_uri(@uri_stack.pop)
    end
  end
end
