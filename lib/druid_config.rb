# Global library
require 'httparty'

# Classes
require 'druid_config/zk'
require 'druid_config/entities/segment'
require 'druid_config/entities/data_source'
require 'druid_config/cluster'
require 'druid_config/client'

# Base namespace of the gem
module DruidConfig
  # Global client of Druidconfig module
  @@client = nil

  #
  # Initialize the current client
  #
  def self.client=(client)
    @@client = client
  end

  #
  # Return initialized client
  #
  def self.client
    @@client
  end
end
