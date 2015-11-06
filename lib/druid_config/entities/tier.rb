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
        return @free if @free
        @free = (max_size - size) > 0 ? (max_size - size) : 0
      end

      def used_percent
        return 0 unless max_size && max_size != 0
        ((size.to_f / max_size) * 100).round(2)
      end

      def historicals
        nodes.select { |node| node.type == :historical }
      end

      def segments
        @segments ||= nodes.map(&:segments)
                      .flatten.sort_by { |seg| seg.interval.first }
      end

      def segments_count
        @segments_count ||= nodes.map(&:segments_count).inject(:+)
      end

      def segments_to_load
        @segments_to_load ||= nodes.map(&:segments_to_load)
                              .flatten.sort_by { |seg| seg.interval.first }
      end

      def segments_to_drop
        @segments_to_drop ||= nodes.map(&:segments_to_drop)
                              .flatten.sort_by { |seg| seg.interval.first }
      end

      def segments_to_load_count
        @segments_to_load_count ||=
          nodes.map(&:segments_to_load_count).inject(:+)
      end

      def segments_to_drop_count
        @segments_to_drop_count ||=
          nodes.map(&:segments_to_drop_count).inject(:+)
      end

      def segments_to_load_size
        @segments_to_load_size ||=
          nodes.map(&:segments_to_load_size).reduce(:+)
      end

      def segments_to_drop_size
        @segments_to_drop_size ||=
          nodes.map(&:segments_to_drop_size).reduce(:+)
      end
    end
  end
end
