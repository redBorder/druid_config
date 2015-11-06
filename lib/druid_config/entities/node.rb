module DruidConfig
  module Entities
    #
    # Node class
    #
    class Node
      # HTTParty Rocks!
      include HTTParty
      include DruidConfig::Util

      # Readers
      attr_reader :host, :port, :max_size, :type, :tier, :priority, :size,
                  :segments_to_load_count, :segments_to_drop_count,
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
        # Set end point for HTTParty
        self.class.base_uri(
          "#{DruidConfig.client.coordinator}"\
          "druid/coordinator/#{DruidConfig::Version::API_VERSION}")

        # Load more data from queue
        if queue.nil?
          @segments_to_load_count, @segments_to_drop_count = 0, 0
          @segments_to_load_size, @segments_to_drop_size = 0, 0
        else
          @segments_to_load_count = queue['segmentsToLoad']
          @segments_to_drop_count = queue['segmentsToDrop']
          @segments_to_load_size = queue['segmentsToLoadSize']
          @segments_to_drop_size = queue['segmentsToLoadSize']
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
        return @free if @free
        @free = (max_size - size) > 0 ? (max_size - size) : 0
      end

      #
      # Return all segments of this node
      #
      def segments_count
        @segments_count ||=
          self.class.get("/servers/#{uri}/segments").size
      end

      #
      # Return all segments of this node
      #
      def segments
        @segments ||=
          self.class.get("/servers/#{uri}/segments?full").map do |s|
            DruidConfig::Entities::Segment.new(s)
          end
      end

      #
      # Get segments to load
      #
      def segments_to_load
        current_queue = queue
        return [] unless current_queue
        current_queue['segmentsToLoad'].map do |segment|
          DruidConfig::Entities::Segment.new(segment)
        end
      end

      #
      # Get segments to drop
      #
      def segments_to_drop
        current_queue = queue
        return [] unless current_queue
        current_queue['segmentsToDrop'].map do |segment|
          DruidConfig::Entities::Segment.new(segment)
        end
      end

      #
      # Return the URI of this node
      #
      def uri
        "#{@host}:#{@port}"
      end

      private

      #
      # Get load queue for this node
      #
      def queue
        secure_query do
          self.class.get('/loadqueue?full')
            .select { |k, _| k == uri }.values.first
        end
      end
    end
  end
end
