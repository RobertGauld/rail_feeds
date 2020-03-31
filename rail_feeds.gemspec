# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.join(File.dirname(__FILE__), 'lib', 'rail_feeds', 'version')

Gem::Specification.new do |gem|
  gem.name        = 'rail_feeds'
  gem.license     = 'BSD 3 clause'
  gem.version     = RailFeeds::Version
  gem.authors     = ['Robert Gauld']
  gem.email       = ['robert@robertgauld.co.uk']
  gem.homepage    = 'https://github.com/robertgauld/rail_feeds'
  gem.summary     = 'Make use of the various open data rails feeds in the UK.'
  gem.description = 'Make use of the various open data rails feeds in the UK. Currently only some from Network Rail.'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.required_ruby_version     = '>= 2.4'
  gem.required_rubygems_version = '>= 2.6.14'

  gem.add_dependency 'nokogiri', '~> 1.10', '>= 1.10.5'
  gem.add_dependency 'stomp', '~> 1.4'

  gem.add_development_dependency 'coveralls', '~> 0.7'
  gem.add_development_dependency 'guard-rspec', '~> 4.2', '>= 4.2.5'
  gem.add_development_dependency 'guard-rubocop', '~> 1.3'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rb-inotify', '~> 0.9'
  gem.add_development_dependency 'rspec', '>= 3.7', '< 4'
  gem.add_development_dependency 'rubocop', '~> 0.67'
  gem.add_development_dependency 'rubocop-performance', '~> 1.1'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'timecop', '~> 0.5'
end
