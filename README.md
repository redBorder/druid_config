[![Gem Version](https://badge.fury.io/rb/druid_config.svg)](https://badge.fury.io/rb/druid_config) [![Build Status](https://travis-ci.org/redBorder/druid_config.svg)](https://travis-ci.org/redBorder/druid_config)

# DruidConfig

DruidConfig is a gem to access the information about Druid cluster status. You can check a node capacity, number of segments, tiers... It uses [zookeeper](https://zookeeper.apache.org/) to get coordinator and overlord URIs.

To use in your application, add this line to your Gemfile:

```ruby
gem 'druid_config'
```

## Query Druid data

The purpose of this gem is to query Druid cluster status. If you want to query Druid data, I recommend you to use [ruby-druid gem](https://github.com/ruby-druid/ruby-druid).

# Initialization

`Cluster` is the base class to perform queries. To initialize it send the Zookeeper URI and options as arguments:

```ruby
cluster = DruidConfig::Cluster.new(zookeeper_uri, options)
```

Available options:
* discovery_path: string with the discovery path of druid inside Zookeeper directory structure.

# Usage

Call methods defined in `DruidConfig::Cluster` to access to the data. To get more information about data returned in methods, check [Druid documentation](http://druid.io/docs/0.8.1/design/coordinator.html).

* `leader`: leader
* `load_status`: load status
* `load_status`: load queue
* `metadata_datasources`: Hash with metadata of datasources
* `metadata_datasources_segments`: Hash with metadata of segments
* `datasources`: all data sources
* `datasource`: a concrete data source
* `rules`: all rules defined in the cluster
* `tiers`: tiers
* `servers` or `nodes`: all nodes of the cluster
* `physical_servers` or `physical_nodes`: array of URIs of nodes
* `historicals`: historical nodes
* `realtimes`: realtime nodes
* `workers`: worker nodes
* `physical_workers`: array of URIs of worker nodes
* `running_tasks`, `pending_tasks`, `waiting_tasks`, `complete_tasks`: tasks in the cluster based in their status
* `task`: load a task based on an identifier
* `services`: Hash with physical nodes and the services they are running

## Entities

Some methods return an instance of an `Entity` class. These entities provide multiple methods to access data. Defined entities are inside `druid_config/entities` folder.

* [DataSource](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/data_source.rb)
* [Segment](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/segment.rb)
* [Tier](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/tier.rb)
* [Node](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/node.rb)
* [Worker](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/worker.rb)
* [Task](https://github.com/redBorder/druid_config/blob/master/lib/druid_config/entities/task.rb)

## Exceptions

### DruidConfig::Exceptions::NotAvailableNodes

This exception will be raised when you try to perform a query to a Druid Coordinator or Overlord but there aren't any node of that type available.

### DruidConfig::Exceptions::DruidApiError

Sometimes the Gem have available nodes, but it can't access to Druid API. In this case, the gem automatically will reset the Zookeeper connection and retry the query. If second query fails too, a `DruidConfig::Exceptions::DruidApiError` exception will be raised.

# Collaborate

To contribute DruidConfig:

* Create an issue with the contribution: bug, enhancement or feature
* Fork the repository and make all changes you need
* Write test on new changes
* Create a pull request when you finish

# License

DruidConfig gem is released under the Affero GPL license. Copyright [redBorder](http://redborder.net)