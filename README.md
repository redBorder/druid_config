# DruidConfig

DruidConfig is a gem to access the information about Druid cluster status. You can check a node capacity, number of segments, tiers... It uses [zookeeper](https://zookeeper.apache.org/) to get coordinator and overlord URIs.

To use in your application, add this line to your Gemfile:

```ruby
require 'druid_config'
```

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
* `services`: Hash with physical nodes and the services they are running

## Entities

Some methods return an instance of an `Entity` class. These entities provide multiple methods to access data. Defined entities are inside `druid_config/entities` folder.

*[DataSource]()
*[Node]()
*[Segment]()
*[Tier]()
*[Worker]()

# Collaborate

To contribute DruidConfig:

* Create an issue with the contribution: bug, enhancement or feature
* Fork the repository and make all changes you need
* Write test on new changes
* Create a pull request when you finish

# License

DruidConfig gem is released under the Affero GPL license. Copyright [redBorder](http://redborder.net)