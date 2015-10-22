require File.expand_path('../lib/druid_config/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'druid_config'
  s.version     = DruidConfig::VERSION
  s.summary     = 'Fetch Druid info and configure your cluster'
  s.description = 'Fetch Druid info using Druid API. You can fetch all data '\
                  'related to your nodes, data sources, segments...'
  s.authors     = ['Angel M Miguel']
  s.email       = 'angelmm@redborder.net'
  s.files       = Dir['lib/**/*'] + %w(LICENSE README.md)
  s.homepage    = 'http://redborder.net'
  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']
  s.licenses     = ['AGPL']
  # Main dependencies
  s.add_dependency 'zk', '1.9.6'
  s.add_dependency 'httparty', '0.13.7'
  s.add_dependency 'rest-client', '1.8.0'
  # Dependencies for testing
  s.add_development_dependency 'rspec', '>= 3.2'
  s.add_development_dependency 'rspec-rails', '>= 3.2'
  s.add_development_dependency 'sqlite3', '1.3.11'
  s.add_development_dependency 'pry', '0.10.3'
  s.add_development_dependency 'pry-nav', '0.2.4'
  s.add_development_dependency 'webmock', '1.22.1'
end
