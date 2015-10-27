require 'spec_helper'
require 'pry'
require 'pry-nav'

describe DruidConfig::Cluster do
  before(:each) do
    @cluster = DruidConfig::Cluster.new('localhost', zk_keepalive: true)
  end

  it 'must get the leader' do
    expect(@cluster.leader).to eq 'coordinator.stub'
  end

  it 'must get load status' do
    basic = @cluster.load_status
    expect(basic.keys).to eq %w(datasource1 datasource2)
    expect(basic[basic.keys.first]).to eq 100

    simple = @cluster.load_status('simple')
    expect(simple.keys).to eq %w(datasource1 datasource2)
    expect(simple[simple.keys.first]).to eq 0

    full = @cluster.load_status('full')
    expect(full.keys).to eq %w(_default_tier hot)
    expect(full['_default_tier']['datasource1']).to eq 0
    expect(full['hot']['datasource2']).to eq 0
  end
end
