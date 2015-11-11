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
    end
  end
end
    