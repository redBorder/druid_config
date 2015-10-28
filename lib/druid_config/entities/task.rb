module DruidConfig
  #
  # Module of Entities
  #
  module Entities
    #
    # Init a DataSource
    class Task
      # HTTParty Rocks!
      include HTTParty
      include DruidConfig::Util

      # Statuses constants
      STATUS = {
        running: 'RUNNING',
        pending: 'PENDING',
        success: 'SUCCESS',
        waiting: 'WAITING',
        failed: 'FAILED'
      }

      attr_reader :id, :status, :created_time, :query_insertion_time

      #
      # Initialize a task
      #
      # == Parameters:
      # id::
      #   String with identifier
      # status::
      #   Current status of the task
      #
      def initialize(id, status, extended_info = {})
        @id = id
        @status = status.downcase.to_sym
        @created_time = extended_info[:created_time]
        @query_insertion_time = extended_info[:query_insertion_time]

        # Set end point for HTTParty
        self.class.base_uri(
          "#{DruidConfig.client.overlord}"\
          "druid/indexer/#{DruidConfig::Version::API_VERSION}/task")
      end

      #
      # Multiple methods to check status of the tasks
      #
      STATUS.keys.each do |s|
        define_method("#{s}?") do
          s.to_sym == @status
        end
      end

      alias_method :completed?, :success?

      #
      # Get payload of the task
      #
      def payload
        @payload ||= self.class.get("/#{@id}")['payload']
      end

      #
      # Get the dataSource of this task
      #
      def datasource
        payload['dataSource']
      end

      #
      # Group of the task
      #
      def group_id
        payload['groupId']
      end
    end
  end
end
