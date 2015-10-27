#
# Define the versions of the gem.
#
module DruidConfig
  #
  # Commmon functions for the gem
  #
  module Util
    #
    # This method is used to protect the Gem to API errors. If a query fails,
    # the client will be reset and try the query to new coordinator. If it
    # fails too, a DruidApiError will be launched.
    #
    # If the error comes from another point of the code, the Exception
    # is launched normally
    #
    def secure_query
      return unless block_given?
      @retries = 0
      begin
        yield
      rescue HTTParty::RedirectionTooDeep => e
        raise(DruidApiError, e) if @retries > 0
        @retries += 1
        reset!
        retry
      rescue Errno::ECONNREFUSED => e
        raise(DruidApiError, e) if @retries > 0
        @retries += 1
        reset!
        retry
      end
    end
  end
end
