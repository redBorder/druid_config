# Global library
require 'httparty'
require 'iso8601'
require 'delegate'
require 'json'
require 'net/http'

# Classes
require 'druid_config/zk'
require 'druid_config/version'
require 'druid_config/util'
require 'druid_config/entities/segment'
require 'druid_config/entities/rule'
require 'druid_config/entities/rule_collection'
require 'druid_config/entities/task'
require 'druid_config/entities/worker'
require 'druid_config/entities/node'
require 'druid_config/entities/tier'
require 'druid_config/entities/data_source'
require 'druid_config/cluster'
require 'druid_config/client'

# Base namespace of the gem
module DruidConfig
  #
  # Exception class for an error to connect the API
  #
  class DruidApiError < StandardError; end
  
  # Global client of Druidconfig module
  @client = nil

  #
  # Initialize the current client
  #
  def self.client=(client)
    @client = client
  end

  #
  # Return initialized client
  #
  def self.client
    @client
  end
end
