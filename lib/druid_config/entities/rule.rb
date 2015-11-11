module DruidConfig
  module Entities
    #
    # Rule class
    #
    class Rule
      # Variables
      attr_reader :datasource, :type, :rule_type, :replicants, :period,
                  :interval

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
      def self.parse(datasource, data)
        rule_type, type = detect_type(data['type'])
        options = { replicants: data['tieredReplicants'] }
        if type == :period
          options.merge!(period: data['period'])
        elsif type == :interval
          options.merge!(interval: data['interval'])
        end
        # Instance the class
        new(datasource, rule_type, type, options)
      end

      #
      # Initialize a Rule object. This constructor accepts a Hash with
      # format defined in:
      #   http://druid.io/docs/latest/operations/rule-configuration.html
      #
      # == Parameters:
      # datasource::
      #   String with the name of the data source
      # rule_type::
      #   Type of the rule, it can be :drop or :load
      # type::
      #   Time reference. It can be :forever, :period or :interval
      # options::
      #   Hash with extra data to the rules.
      #     - replicants: Hash with format
      #         { 'tier' >= NumberOfReplicants, 'tier' => ... }
      #     - period: String with a period in ISO8601 format.
      #               Only available when type is :period.
      #     - interval: String with a interval in ISO8601 format.
      #                 Only available when type is :interval.
      #
      def initialize(datasource, rule_type, type, options = {})
        @datasource = datasource
        @rule_type = rule_type
        @type = type
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
      %i(drop load).each do |rule|
        define_method("#{rule}?") do
          @rule_type == rule
        end
      end

      #
      # Functions to check how rule time is defined
      #
      %i(interval forever period).each do |time|
        define_method("#{time}?") do
          @type == time
        end
      end

      #
      # Detect the type of the rule based on 'type' field. This method will
      # detect if is a drop/load rule and how it defines time.
      #
      # == Parameters:
      # type::
      #   String with the content of type field
      #
      def self.detect_type(type)
        rule_type = type.starts_with?('drop') ? :drop : :load
        type = case type.gsub(rule_type.to_s, '')
               when 'ByInterval'
                 :interval
               when 'Forever'
                 :forever
               when 'ByPeriod'
                 :period
               end
        [rule_type, type]
      end
    end
  end
end
