module DruidConfig
  #
  # Module of Entities
  #
  module Entities
    #
    # Init a DataSource
    class DataSource
      # HTTParty Rocks!
      include HTTParty
      include DruidConfig::Util

      attr_reader :name, :properties, :load_status

      #
      # Initialize a DataSource
      #
      def initialize(metadata, load_status)
        @name = metadata['name']
        @properties = metadata['properties']
        @load_status = load_status
        # Set end point for HTTParty
        self.class.base_uri(
          "#{DruidConfig.client.coordinator}"\
          "druid/coordinator/#{DruidConfig::Version::API_VERSION}")
      end

      #
      # The following methods are referenced to Druid API. To check the
      # funcionality about it, please go to Druid documentation:
      #
      # http://druid.io/docs/0.8.1/design/coordinator.html
      #

      def info
        secure_query do
          @info ||= self.class.get("/datasources/#{@name}")
        end
      end

      # Intervals
      # -----------------
      def intervals(params = '')
        secure_query do
          self.class.get("/datasources/#{@name}/intervals?#{params}")
        end
      end

      def interval(interval, params = '')
        secure_query do
          self.class.get("/datasources/#{@name}/intervals/#{interval}"\
                         "?#{params}")
        end
      end

      # Segments and Tiers
      # -----------------
      def segments
        secure_query do
          @segments ||=
            self.class.get("/datasources/#{@name}/segments?full").map do |s|
              DruidConfig::Entities::Segment.new(s)
            end
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
        secure_query do
          self.class.get("/rules/#{@name}?#{params}")
        end
      end

      def history_rules(interval)
        secure_query do
          self.class.get("/rules/#{@name}/history"\
                         "?interval=#{interval}")
        end
      end
    end
  end
end
