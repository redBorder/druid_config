require 'spec_helper'

describe DruidConfig::Entities::DataSource do
  before(:each) do
    @name = 'datasource'
    @properties = { 'client' => 'side' }
    @metadata = { 'name' => @name, 'properties' => @properties }
    @load_status = 100
  end

  it 'initialize the model based on metadata' do
    datasource = DruidConfig::Entities::DataSource.new(@metadata, @load_status)
    expect(datasource.name).to eq @name
    expect(datasource.properties).to eq @properties
    expect(datasource.load_status).to eq @load_status
  end
end
