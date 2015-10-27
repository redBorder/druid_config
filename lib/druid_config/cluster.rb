module DruidConfig
  #
  # Class to initialize the connection to Zookeeper
  #
  class Cluster
    # HTTParty Rocks!
    include HTTParty
    include DruidConfig::Util

    #
    # Initialize the client to perform the queries
    #
    # == Parameters:
    # zk_uri::
    #   String with URI or URIs (sparated by comma) of Zookeeper
    # options::
    #   Hash with options:
    #     - discovery_path: String with the discovery path of Druid
    #
    def initialize(zk_uri, options)
      # Initialize the Client
      DruidConfig.client = DruidConfig::Client.new(zk_uri, options)

      # Used to check the number of retries on error
      @retries = 0

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

    #
    # Reset the client
    #
    def reset!
      DruidConfig.client.reset!
      self.class.base_uri(
        "#{DruidConfig.client.coordinator}"\
        "druid/coordinator/#{DruidConfig::Version::API_VERSION}")
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
 
    #
    # Return the leader of the Druid cluster
    #
    def leader
      secure_query do
        self.class.get('/leader').body
      end
    end

    #
    # Load status of the cluster
    #
    def load_status(params = '')
      secure_query do
        self.class.get("/loadstatus?#{params}")
      end
    end

    #
    # Load queue of the cluster
    #
    def load_queue(params = '')
      secure_query do
        self.class.get("/loadqueue?#{params}")
      end
    end

    # Metadata
    # -----------------
    
    #
    # Return a Hash with metadata of datasources
    #
    def metadata_datasources(params = '')
      secure_query do
        self.class.get("/metadata/datasources?#{params}")
      end
    end

    alias_method :mt_datasources, :metadata_datasources

    #
    # Return a Hash with metadata of segments
    #
    # == Parameters:
    # data_source::
    #   String with the name of the data source
    # segment::
    #   (Optional) Segment to search
    #
    def metadata_datasources_segments(data_source, segment = '')
      end_point = "/metadata/datasources/#{data_source}/segments"
      secure_query do
        if segment.empty? || segment == 'full'
          self.class.get("#{end_point}?#{params}")
        else
          self.class.get("#{end_point}/#{params}")
        end
      end
    end

    alias_method :mt_datasources_segments, :metadata_datasources_segments

    # Data sources
    # -----------------
    
    #
    # Return all datasources
    #
    # == Returns:
    # Array of Datasource initialized.
    #
    def datasources
      datasource_status = load_status
      secure_query do
        self.class.get('/datasources?full').map do |data|
          DruidConfig::Entities::DataSource.new(
            data,
            datasource_status.select { |k, _| k == data['name'] }.values.first)
        end
      end
    end

    #
    # Return a unique datasource
    #
    # == Parameters:
    # datasource:
    #   String with the data source name
    #
    # == Returns:
    # DataSource instance
    #
    def datasource(datasource)
      datasources.select { |el| el.name == datasource }
    end

    # Rules
    # -----------------
    
    #
    # Return the rules applied to a cluster
    #
    def rules
      secure_query do
        self.class.get('/rules')
      end
    end

    # Tiers
    # -----------------
 
    #
    # Return all tiers defined in the cluster
    #
    # == Returns:
    # Array of Tier instances
    #
    def tiers
      current_nodes = servers
      # Initialize tiers
      secure_query do
        current_nodes.map(&:tier).uniq.map do |tier|
          DruidConfig::Entities::Tier.new(
            tier,
            current_nodes.select { |node| node.tier == tier })
        end
      end
    end

    # Servers
    # -----------------

    #
    # Return all nodes of the cluster
    #
    # == Returns:
    # Array of node Objects
    #
    def servers
      secure_query do
        queue = load_queue('full')
        self.class.get('/servers?full').map do |data|
          DruidConfig::Entities::Node.new(
            data,
            queue.select { |k, _| k == data['host'] }.values.first)
        end
      end
    end

    #
    # URIs of the physical servers in the cluster
    #
    # == Returns:
    # Array of strings
    #
    def physical_servers
      secure_query do
        @physical_servers ||= servers.map(&:host).uniq
      end
    end

    alias_method :nodes, :servers
    alias_method :physical_nodes, :physical_servers

    #
    # Returns only historial nodes
    #
    # == Returns:
    # Array of Nodes
    #
    def historicals
      servers.select { |node| node.type == :historical }
    end

    #
    # Returns only realtime
    #
    # == Returns:
    # Array of Nodes
    #
    def realtimes
      servers.select { |node| node.type == :realtime }
    end

    #
    # Return all Workers (MiddleManager) of the cluster
    #
    # == Returns:
    # Array of Workers
    #
    def workers
      # Stash the base_uri
      stash_uri
      self.class.base_uri(
        "#{DruidConfig.client.overlord}"\
        "druid/indexer/#{DruidConfig::Version::API_VERSION}")
      workers = []
      # Perform a query
      begin
        secure_query do
          workers = self.class.get('/workers').map do |worker|
            DruidConfig::Entities::Worker.new(worker)
          end
        end
      ensure
        # Recover it
        pop_uri
      end
      # Return
      workers
    end

    #
    # URIs of the physical workers in the cluster
    #
    def physical_workers
      @physical_workers ||= workers.map(&:host).uniq
    end

    # Services
    # -----------------
    
    #
    # Availabe services in the cluster
    #
    # == Parameters:
    # Array of Hash with the format:
    #   { server: [ services ], server2: [ services ], ... }
    #
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
