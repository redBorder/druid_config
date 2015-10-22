require 'spec_helper'
require 'pry'
require 'pry-nav'

describe DruidConfig::Cluster do
  it 'must get the leader' do
    cluster = DruidConfig::Cluster.new('localhost', zk_keepalive: true)
    expect(cluster.leader).to eq 'coordinator.stub'
  end
end
