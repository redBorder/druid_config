module DruidConfig
  module Entities
    #
    # Node class
    #
    class Node
      # HTTParty Rocks!
      include HTTParty

      # Readers
      attr_reader :host, :max_size, :type, :tier, :priority, :size, :segments

      #
      # Initialize it with received info
      #
      # == Parameters:
      # metadata::
      #   Hash with the data of the node given by a Druid API query
      #
      def initialize(metadata)
        @host = metadata['host']
        @max_size = metadata['maxSize']
        @type = metadata['type'].to_sym
        @priority = metadata['priority']
        @size = metadata['currSize']
        @segments = metadata['segments'].map do |_, sdata|
          DruidConfig::Entities::Segment.new(sdata)
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
