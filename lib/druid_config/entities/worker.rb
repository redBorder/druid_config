module DruidConfig
  module Entities
    #
    # Worker class
    #
    class Worker
      # Readers
      attr_reader :last_completed_task_time, :host, :port, :ip, :capacity,
                  :version, :running_tasks, :capacity_used

      #
      # Initialize it with received info
      #
      # == Parameters:
      # metadata::
      #   Hash with returned metadata from Druid
      #
      def initialize(metadata)
        @host, @port = metadata['worker']['host'].split(':')
        @ip = metadata['worker']['ip']
        @capacity = metadata['worker']['capacity']
        @version = metadata['worker']['version']
        @last_completed_task_time = metadata['lastCompletedTaskTime']
        @running_tasks = metadata['runningTasks'].map do |task|
          DruidConfig::Entities::Task.new(
            task,
            DruidConfig::Entities::Task::STATUS[:running],
            created_time: task['createdTime'],
            query_insertion_time: task['queueInsertionTime'])
        end
        @capacity_used = metadata['currCapacityUsed']
      end

      alias_method :used, :capacity_used

      #
      # Return free capacity
      #
      def free
        @free ||= (capacity - capacity_used)
      end

      #
      # Return capacity used
      #
      def used_percent
        return 0 unless @capacity && @capacity != 0
        ((@capacity_used.to_f / @capacity) * 100).round(2)
      end

      #
      # Return the uri of the worker
      #
      def uri
        "#{@host}:#{@port}"
      end
    end
  end
end
