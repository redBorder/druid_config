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

      # Name of default datasource
      DEFAULT_DATASOURCE = '_default'.freeze

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

      # Enable the current data source
      #
      def enable
        secure_query do
          self.class.post("/datasources/#{@name}")
        end
      end

      # Disable the current data source
      #
      def disable
        secure_query do
          self.class.delete("/datasources/#{@name}")
        end
      end

      # Destroy the current data source. Becareful, this action will remove the
      # data associated to the data source
      #
      # @param interval [String] Optional parameter to define the interval to
      #   destroy the data associated to the data source. By default, it will
      #   destroy all data.
      #
      # @return [Hash, nil] Hash with error or nil
      #
      def destroy(interval = nil)
        interval = all_interval unless interval
        # Disable data source
        disable
        # Execute kill task
        secure_query do
          self.class.delete(
            "/datasources/#{@name}?kill=true&interval=#{interval}")
        end
      end

      # Destroy current data source

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
        return @rules if @rules
        @rules = DruidConfig::Entities::RuleCollection.new
        secure_query do
          self.class.get("/rules/#{@name}?#{params}").each do |rule|
            @rules << DruidConfig::Entities::Rule.parse(rule)
          end
        end
        @rules
      end

      #
      # Apply given rules to the datasource
      #
      # == Paremeters:
      # rules::
      #   RuleCollection of rules
      #
      # == Returns:
      # Boolean indicating the status of the request
      #
      def update_rules(new_rules)
        if post_rules(new_rules)
          @rules = new_rules
          true
        else
          false
        end
      end

      #
      # Save current rules
      #
      # == Returns:
      # Boolean indicating the status of the request
      #
      def save_rules
        post_rules(rules)
      end

      def history_rules(interval)
        secure_query do
          self.class.get("/rules/#{@name}/history"\
                         "?interval=#{interval}")
        end
      end

      private

      # Return an ISO8601 interval from 0 to tomorrow. This is used to destroy
      # all the data of a data source
      #
      # @return [String] ISO8601 interval
      #
      def all_interval
        beginning = '1970-01-01T00:00:00Z'
        # We use today + 1.day to ensure all data is deleted
        last = (Time.now + 24*60*60).strftime('%Y-%m-%dT%H:%M:00Z')
        # Return the interval
        "#{beginning}/#{last}"
      end

      #
      # Save rules of this data source
      #
      # == Paremeters:
      # rules::
      #   RuleCollection of rules
      #
      # == Returns:
      # Boolean indicating the status of the request
      #
      def post_rules(new_rules)
        fail(ArgumentError, 'Rules must be a RuleCollection instance') unless
          new_rules.is_a?(RuleCollection)
        uri = URI("#{self.class.base_uri}/rules/#{name}")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request['Content-Type'] = 'application/json'
        request.body = new_rules.map(&:to_h).to_json
        response = http.request(request)
        # Check statys
        response.code.to_i == 200
      end
    end
  end
end
