module DruidConfig
  module Entities
    #
    # Node class
    #
    class Node
      # HTTParty Rocks!
      include HTTParty

      # Readers
      attr_reader :host, :max_size, :type, :tier, :priority, :size,
                  :segments, :segments_to_load, :segments_to_drop

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
        @host = metadata['host']
        @max_size = metadata['maxSize']
        @type = metadata['type'].to_sym
        @tier = metadata['tier']
        @priority = metadata['priority']
        @size = metadata['currSize']
        @segments = metadata['segments'].map do |_, sdata|
          DruidConfig::Entities::Segment.new(sdata)
        end
        if queue.nil?
          @segments_to_load = []
          @segments_to_drop = []
        else
          @segments_to_load = queue['segmentsToLoad'].map do |segment|
            DruidConfig::Entities::Segment.new(segment)
          end
          @segments_to_drop = queue['segmentsToDrop'].map do |segment|
            DruidConfig::Entities::Segment.new(segment)
          end
        end
      end

      #
      # Calculate the percent of used space
      #
      def used
        return 0 unless max_size && max_size != 0
        ((size.to_f / max_size) * 100).round(2)
      end

      #
      # Calculate free space
      #
      def free
        max_size - size
      end
    end
  end
end
