# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Prerelase

- Protect free memory against negative values.

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