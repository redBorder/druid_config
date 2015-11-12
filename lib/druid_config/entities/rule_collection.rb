module DruidConfig
  module Entities
    #
    # Rule set of a data source
    #
    class RuleCollection < Array
      #
      # Check the consistency of the rules. For example, if you define the
      # following rules:
      #
      # 1 - LOAD ByPeriod PT12M replicants -> { _default_tier => 1 }
      # 2 - LOAD ByPeriod PT3M replicants -> { _default_tier => 1 }
      #
      # The second rule never be applied.
      #
      # This method don't raise any exception and your Druid installation will
      # work unless there are an inconsistence. The purpose of this method is
      # to advise you could be wrong about rules
      #
      # == Returns:
      # A boolean. True when the rules are consistent.
      #
      def consistent?
        # TODO: implement this method
        true
      end

      #
      # Return the collection of rules as a valid JSON for Druid
      #
      # == Parameters:
      # include_datasources::
      #   True if you want to include the name of the datasources as keys
      #   (False by default)
      #
      # == Returns:
      # JSON String
      #
      def to_json(include_datasources = false)
        return to_json_with_datasources if include_datasources
        map(&:to_h).to_json
      end

      private

      #
      # Return a JSON string with the datasources and the rules associated to
      # them
      #
      # == Returns:
      # JSON string with format:
      #   { 'datasource' => [ { "type" => ... }, ...], 'datasource2' => [...] }
      #
      def to_json_with_datasources
        rules_with_ds = {}
        map do |rule|
          rules_with_ds[rule.datasource] ||= []
          rules_with_ds[rule.datasource] << rule.to_h
        end
        rules_with_ds.to_json
      end
    end
  end
end
    