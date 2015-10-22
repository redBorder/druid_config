require 'spec_helper'
require 'pry'
require 'pry-nav'

# describe DruidConfig::Cluster do
#   before(:each) do
#     @cluster = DruidConfig::Cluster.new('localhost', zk_keepalive: true)
#   end

#   it 'must get the leader' do
#     expect(@cluster.leader).to eq 'coordinator.stub'
#   end

#   it 'must get load datasources of a cluster' do
#     datasources = @cluster.datasources


#     # basic = @cluster.load_status
#     # expect(basic.keys).to eq %w(datasource1 datasource2)
#     # expect(basic[basic.keys.first]).to eq 100

#     # simple = @cluster.load_status('simple')
#     # expect(simple.keys).to eq %w(datasource1 datasource2)
#     # expect(simple[simple.keys.first]).to eq 0

#     # # Use tiers
#     # simple = @cluster.load_status('full')
#     # expect(simple.keys).to eq %w(_default_tier hot)
#     # expect(simple['_default_tier']['datasource1']).to eq 0
#     # expect(simple['hot']['datasource2']).to eq 0
#   end
# end
