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
        raise(DruidConfig::Exceptions::DruidApiError, e) if @retries > 0
        @retries += 1
        reset!
        retry
      rescue Errno::ECONNREFUSED => e
        raise(DruidConfig::Exceptions::DruidApiError, e) if @retries > 0
        @retries += 1
        reset!
        retry
      end
    end

    #
    # Update the URI of HTTParty to perform queries to Overlord.
    # After perform the query, the URI is reverted to coordinator.
    #
    def query_overlord
      return unless block_given?
      stash_uri
      self.class.base_uri(
        "#{DruidConfig.client.overlord}"\
        "druid/indexer/#{DruidConfig::Version::API_VERSION}")
      begin
        yield
      ensure
        # Ensure we revert the URI
        pop_uri
      end
    end

    #
    # Stash current base_uri
    #
    def stash_uri
      @uri_stack ||= []
      @uri_stack.push self.class.base_uri
    end

    #
    # Pop next base_uri
    #
    def pop_uri
      return if @uri_stack.nil? || @uri_stack.empty?
      self.class.base_uri(@uri_stack.pop)
    end
  end
end
