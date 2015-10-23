require 'spec_helper'

describe DruidConfig::Entities::Node do
  before(:each) do
    @host = 'stubbed.cluster:8083'
    @max_size = 100_000
    @type = 'historical'
    @priority = 0
    @segments = {
      'datasource_2015-10-22T15:00:00.000Z_2015-10-22T16:00:00.000Z_2015-10-22T15:00:17.214Z' => {
        'dataSource' => 'datasource',
        'interval' => '2015-10-22T15:00:00.000Z/2015-10-22T16:00:00.000Z',
        'version' => '2015-10-22T15:00:17.214Z',
        'loadSpec' => {},
        'dimensions' => '',
        'metrics' => 'events,sum_bytes',
        'shardSpec' => {
          'type' => 'linear',
          'partitionNum' => 0
        },
        'binaryVersion' => nil,
        'size' => 0,
        'identifier' => 'datasource_2015-10-22T15:00:00.000Z_2015-10-22T16:00:00.000Z_2015-10-22T15:00:17.214Z'
      }
    }
    @size = 50_000
    @metadata = { 'host' => @host, 'maxSize' => @max_size, 'type' => @type,
                  'priority' => 0, 'segments' => @segments, 'currSize' => @size }
    
    @queue = {
      'segmentsToLoad' => [],
      'segmentsToDrop' => []
    }
  end

  it 'initialize a Node based on metadata' do
    datasource = DruidConfig::Entities::Node.new(@metadata, @queue)
    expect(datasource.host).to eq @host
    expect(datasource.max_size).to eq @max_size
    expect(datasource.type).to eq @type.to_sym
    expect(datasource.priority).to eq @priority
    expect(datasource.size).to eq @size
    expect(datasource.segments_to_load).to eq []
    expect(datasource.segments_to_drop).to eq []
  end

  it 'calculate free space' do
    datasource = DruidConfig::Entities::Node.new(@metadata, @queue)
    expect(datasource.free).to eq(@max_size - @size)
  end

  it 'calculate percentage of used space' do
    datasource = DruidConfig::Entities::Node.new(@metadata, @queue)
    expect(datasource.used_percent).to eq((@size.to_f / @max_size) * 100)
  end

  it 'return 0 when max size is 0' do
    datasource =
      DruidConfig::Entities::Node.new(@metadata.merge('maxSize' => 0), @queue)
    expect(datasource.used_percent).to eq 0
  end
end
