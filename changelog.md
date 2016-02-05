# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.5.0] - 05-02-2016

- Added `destroy` and `disable` methods to `DataSource` entity [#6](https://github.com/redBorder/druid_config/issues/6)

## [0.4.0] - 24-11-2015

- Fixed verify_node function to retry to connect /status end point three times before ignore the node.
- Don't store old nodes of a service when receive an event from a Zookeeper watcher
- Raise a `DruidConfig::Exceptions::NotAvailableNodes` when there aren't any available
- Fixed an error on `Client` that cause an error when call `.reset` method


## [0.3.0] - 17-11-2015

- Protect free memory against negative values.
- Create Rule entity
- Create RuleCollection entity
- Added a method to udpate rules of a datasource
- Added a method on cluster to return _default data source

## [0.2.0] - 30-10-2015

- Improved worker class with new methods to calculate capacity
- Fixed some bugs on cluster class
- Improve response time by loading segments, segments\_to\_load and segments\_to\_drop on demand
- Added method to cluster to return all tasks or filter them by status
- Created task entity.

## [0.1.0] - 27-10-2015

- Integrate with Travis CI
- Added documentation and README
- Secure queries from connection errors
- Added entities: DataSource, Tier, Node, Worker and Segment
- Added some tests
- Added a class to perform queries: Cluster
- Integrate with Zookeeper
