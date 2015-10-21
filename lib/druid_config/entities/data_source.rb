module DruidConfig
  #
  # Module of info
  #
  module Entities
    #
    # Init a DataSource
    class DataSource
      # HTTParty Rocks!
      include HTTParty

      #
      # Initialize a DataSource
      #
      def initialize(name, client)
        @name = name
        @client = client
        # Update the base uri to perform queries
        self.class.base_uri(
          "#{@client.coordinator}druid/coordinator/#{DruidConfig::API_VERSION}")
      end

      #
      # The following methods are referenced to Druid API. To check the
      # funcionality about it, please go to Druid documentation:
      #
      # http://druid.io/docs/0.8.1/design/coordinator.html
      #

      def info(params = '')
        self.class.get("/datasources/#{@name}?#{params}")
      end

      # Intervals
      # -----------------
      def intervals(params = '')
        self.class.get("/datasources/#{@name}/intervals?#{params}")
      end

      def interval(interval, params = '')
        self.class.get("/datasources/#{@name}/intervals/#{interval}"\
                       "?#{params}")
      end

      # Segments and Tiers
      # -----------------
      def segments(params = '')
        self.class.get("/datasources/#{@name}/segments?#{params}")
      end

      def segment(segment)
        self.class.get("/datasources/#{@name}/segments/#{segment}")
      end

      def tiers
        self.class.get("/datasources/#{@name}/tiers")
      end

      # Rules
      # -----------------
      def rules(params = '')
        self.class.get("/rules/#{@name}?#{params}")
      end

      def history_rules(interval)
        self.class.get("/rules/#{@name}/history"\
                       "?interval=#{interval}")
      end
    end
  end
end
