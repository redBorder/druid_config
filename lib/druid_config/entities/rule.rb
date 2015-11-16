module DruidConfig
  module Entities
    #
    # Rule class
    #
    class Rule
      # Variables
      attr_reader :datasource, :type, :time_type, :replicants, :period,
                  :interval

      # Identifier for type
      FOREVER_DRUID_STRING = 'Forever'
      INTERVAL_DRUID_STRING = 'ByInterval'
      PERIOD_DRUID_STRING = 'ByPeriod'

      #
      # Parse data from a Druid API response an initialize an object of
      # Rule class
      #
      # == Parameters:
      # datasource::
      #   String with the name of the datsource
      # data::
      #   Hash provided by the API
      #
      # == Returns:
      # Rule instance
      #
      def self.parse(data, datasource = nil)
        type, time_type = detect_type(data['type'])
        options = { replicants: data['tieredReplicants'] }
        options.merge!(datasource: datasource) if datasource
        if time_type == :period
          options.merge!(period: data['period'])
        elsif time_type == :interval
          options.merge!(interval: data['interval'])
        end
        # Instance the class
        new(type, time_type, options)
      end

      #
      # Initialize a Rule object. This constructor accepts a Hash with
      # format defined in:
      #   http://druid.io/docs/latest/operations/rule-configuration.html
      #
      # == Parameters:
      # datasource::
      #   String with the name of the data source
      # type::
      #   Type of the rule, it can be :drop or :load
      # time_type::
      #   Time reference. It can be :forever, :period or :interval
      # options::
      #   Hash with extra data to the rules.
      #     - replicants: Hash with format
      #         { 'tier' => NumberOfReplicants, 'tier' => ... }
      #     - period: String with a period in ISO8601 format.
      #               Only available when type is :period.
      #     - interval: String with a interval in ISO8601 format.
      #                 Only available when type is :interval.
      #     - datasource: Name of the datasource
      #
      def initialize(type, time_type, options = {})
        @type = type
        @time_type = time_type
        @datasource = options[:datasource]
        @replicants = options[:replicants]
        if period?
          @period = ISO8601::Duration.new(options[:period])
        elsif interval?
          # TODO: https://github.com/arnau/ISO8601/issues/15
          @interval = options[:interval]
        end
      end

      #
      # Functions to check the rule type
      #
      %w(drop load).each do |rule|
        define_method("#{rule}?") do
          @type == rule.to_sym
        end
      end

      #
      # Functions to check how rule time is defined
      #
      %w(interval forever period).each do |time|
        define_method("#{time}?") do
          @time_type == time.to_sym
        end
      end

      #
      # Return the rule as Hash format
      #
      # == Returns:
      # Hash
      #
      def to_h
        base = { type: type_to_druid }
        base.merge!(tieredReplicants: @replicants) if @replicants
        if period?
          base.merge(period: @period.to_s)
        elsif interval?
          base.merge(interval: @interval.to_s)
        else
          base
        end
      end

      #
      # Return the rule as valid JSON for Druid
      #
      # == Returns:
      # JSON String
      #
      def to_json
        to_h.to_json
      end

      #
      # Detect the type of the rule based on 'type' field. This method will
      # detect if is a drop/load rule and how it defines time.
      #
      # == Parameters:
      # type_to_parse::
      #   String with the content of type field
      #
      def self.detect_type(type_to_parse)
        type = type_to_parse.starts_with?('drop') ? :drop : :load
        time_type = case type_to_parse.gsub(type.to_s, '')
                    when INTERVAL_DRUID_STRING
                      :interval
                    when FOREVER_DRUID_STRING
                      :forever
                    when PERIOD_DRUID_STRING
                      :period
                    end
        [type, time_type]
      end

      private

      #
      # Convert the type to an String Druid can identify
      #
      # == Returns:
      # String with the type of the rule
      #
      def type_to_druid
        time = if period?
                 PERIOD_DRUID_STRING
               elsif interval?
                 INTERVAL_DRUID_STRING
               else
                 FOREVER_DRUID_STRING
               end
        "#{@type}#{time}"
      end
    end
  end
end
