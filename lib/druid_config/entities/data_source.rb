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

      attr_reader :name, :properties

      #
      # Initialize a DataSource
      #
      def initialize(metadata)
        @name = metadata['name']
        @properties = metadata['properties']
        # Set end point for HTTParty
        self.class.base_uri(
          "#{DruidConfig.client.coordinator}"\
          "druid/coordinator/#{DruidConfig::API_VERSION}")
      end

      #
      # The following methods are referenced to Druid API. To check the
      # funcionality about it, please go to Druid documentation:
      #
      # http://druid.io/docs/0.8.1/design/coordinator.html
      #

      def info(params = '')
        @info ||= self.class.get("/datasources/#{@name}?#{params}")
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
      def segments
        @segments ||=
          self.class.get("/datasources/#{@name}/segments?full").map do |s|
            DruidConfig::Entities::Segment.new(s)
          end
      end

      def segment(segment)
        segments.select { |s| s.id == segment }
      end

      def tiers
        info['tiers']
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
