module DruidConfig
  #
  # Module of DruidConfgi exceptions
  #
  module Exceptions
    # Get Global standard error
    class StandardError < ::StandardError; end
    #
    # Indicate there aren't any node available in Zookeeper to run the data.
    # It returns the name of the service user is trying to call.
    #
    class NotAvailableNodes < StandardError
      def initialize(service)
        super("There aren't any available #{service} node")
      end
    end

    #
    # Exception class for an error to connect the API
    #
    class DruidApiError < StandardError; end
  end
end
