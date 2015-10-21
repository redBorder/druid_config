require File.expand_path('../lib/druid_config/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'druid_config'
  s.version     = DruidConfig::VERSION
  s.summary     = 'Fetch Druid info and configure your cluster'
  s.description = 'By using Druid API, you can fetch all data related '\
                  'to your nodes, data sources, segments...'
  s.authors     = ['Angel M Miguel']
  s.email       = 'angelmm@redborder.net'
  s.files       = Dir['lib/**/*'] + %w(LICENSE README.md Rakefile)
  s.homepage    = 'http://redborder.net'
  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']
  s.licenses     = ['AGPL']
  # Main dependencies
  
  # Dependencies for testing
  s.add_development_dependency 'rspec', '>= 3.2'
  s.add_development_dependency 'rspec-rails', '>= 3.2'
  s.add_development_dependency 'sqlite3', '1.3.11'
  s.add_development_dependency 'pry', '0.10.3'
  s.add_development_dependency 'pry-nav', '0.2.4'
end
