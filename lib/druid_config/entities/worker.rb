module DruidConfig
  module Entities
    #
    # Worker class
    #
    class Worker
      # Readers
      attr_reader :last_completed_task_time, :host, :ip, :capacity, :version,
                  :running_tasks, :current_capacity_used

      #
      # Initialize it with received info
      #
      # == Parameters:
      # metadata::
      #   Hash with returned metadata from Druid
      #
      def initialize(metadata)
        @host = metadata['worker']['host']
        @ip = metadata['worker']['ip']
        @capacity = metadata['worker']['capacity']
        @version = metadata['worker']['version']
        @last_completed_task_time = metadata['lastCompletedTaskTime']
        @running_tasks = metadata['runningTasks']
        @capacity_used = metadata['currCapacityUsed']
      end

      #
      # Return free capacity
      #
      def free
        @free ||= (capacity - current_capacity_used)
      end

      #
      # Return capacity used
      #
      def used
        return 0 unless @capacity && @capacity != 0
        ((@capacity_used.to_f / @capacity) * 100).round(2)
      end
    end
  end
end
