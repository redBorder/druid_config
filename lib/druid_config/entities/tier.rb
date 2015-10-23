module DruidConfig
  module Entities
    #
    # Tier class
    #
    class Tier
      # Readers
      attr_reader :name, :nodes
      
      def initialize(name, nodes)
        @name = name
        @nodes = nodes
      end

      alias_method :servers, :nodes

      def size
        @size ||= nodes.map(&:size).inject(:+)
      end

      alias_method :used, :size

      def max_size
        @max_size ||= nodes.map(&:max_size).inject(:+)
      end

      def free
        @free ||= (max_size - size)
      end

      def used_percent
        return 0 unless max_size && max_size != 0
        ((size.to_f / max_size) * 100).round(2)
      end

      def segments
        @segments ||= nodes.map(&:segments)
                      .flatten.sort_by { |seg| seg.interval.first }
      end

      def segments_to_load
        @segments_to_load ||=
          nodes.map { |node| node.segments_to_load.count }.inject(:+)
      end

      def segments_to_drop
        @segments_to_drop ||=
          nodes.map { |node| node.segments_to_drop.count }.inject(:+)
      end
    end
  end
end
