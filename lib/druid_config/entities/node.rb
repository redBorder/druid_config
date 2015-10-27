module DruidConfig
  module Entities
    #
    # Node class
    #
    class Node
      # HTTParty Rocks!
      include HTTParty

      # Readers
      attr_reader :host, :port, :max_size, :type, :tier, :priority, :size,
                  :segments, :segments_to_load, :segments_to_drop,
                  :segments_to_load_size, :segments_to_drop_size

      #
      # Initialize it with received info
      #
      # == Parameters:
      # metadata::
      #   Hash with the data of the node given by a Druid API query
      # queue::
      #   Hash with segments to load
      #
      def initialize(metadata, queue)
        @host, @port = metadata['host'].split(':')
        @max_size = metadata['maxSize']
        @type = metadata['type'].to_sym
        @tier = metadata['tier']
        @priority = metadata['priority']
        @size = metadata['currSize']
        @segments = metadata['segments'].map do |_, sdata|
          DruidConfig::Entities::Segment.new(sdata)
        end
        if queue.nil?
          @segments_to_load, @segments_to_drop = [], []
          @segments_to_load_size, @segments_to_drop_size = 0, 0
        else
          @segments_to_load = queue['segmentsToLoad'].map do |segment|
            DruidConfig::Entities::Segment.new(segment)
          end
          @segments_to_drop = queue['segmentsToDrop'].map do |segment|
            DruidConfig::Entities::Segment.new(segment)
          end
          @segments_to_load_size = @segments_to_load.map(&:size).reduce(:+)
          @segments_to_drop_size = @segments_to_drop.map(&:size).reduce(:+)
        end
      end

      alias_method :used, :size

      #
      # Calculate the percent of used space
      #
      def used_percent
        return 0 unless max_size && max_size != 0
        ((size.to_f / max_size) * 100).round(2)
      end

      #
      # Calculate free space
      #
      def free
        max_size - size
      end

      #
      # Return the URI of this node
      #
      def uri
        "#{@host}:#{@port}"
      end
    end
  end
end
