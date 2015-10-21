module DruidConfig
  module Entities
    #
    # Segment class
    #
    class Segment
      # Readers
      attr_reader :id, :interval, :version, :load_spec, :dimensions, :metrics,
                  :shard_spec, :binary_version, :size

      #
      # Initialize it with received info
      #
      # == Parameters:
      # metadata::
      #   Hash with returned metadata from Druid
      #
      def initialize(metadata)
        @id = metadata['identifier']
        @interval = metadata['interval'].split('/').map { |t| Time.parse t }
        @version = Time.parse metadata['version']
        @load_spec = metadata['loadSpec']
        @dimensions = metadata['dimensions'].split(',').map(&:to_sym)
        @metrics = metadata['metrics'].split(',').map(&:to_sym)
        @shard_spec = metadata['shardSpec']
        @binary_version = metadata['binaryVersion']
        @size = size
      end

      #
      # Return direct link to the store
      #
      # == Returns:
      # String with the URI
      #
      def store_uri
        return '' if load_spec.empty?
        "s3://#{load_spec['bucket']}/#{load_spec['key']}"
      end

      #
      # Return the store type
      #
      # == Returns:
      # Store type as symbol
      #
      def store_type
        return nil if load_spec.empty?
        load_spec['type'].to_sym
      end

      #
      # By default, show the identifier in To_s
      #
      def to_s
        @id
      end
    end
  end
end
