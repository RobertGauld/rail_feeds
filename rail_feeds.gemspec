# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require File.join(File.dirname(__FILE__), 'lib', 'rail_feeds', 'version')

Gem::Specification.new do |s|
  s.name        = 'rail_feeds'
  s.license     = 'BSD 3 clause'
  s.version     = RailFeeds::Version
  s.authors     = ['Robert Gauld']
  s.email       = ['robert@robertgauld.co.uk']
  s.homepage    = 'https://github.com/robertgauld/rail_feeds'
  s.summary     = 'Make use of the various open data rails feeds in the UK.'
  s.description = 'Make use of the various open data rails feeds in the UK. Currently only some from Network Rail.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'stomp', '~> 1.4'

  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'guard-rspec', '~> 4.2', '>= 4.2.5'
  s.add_development_dependency 'guard-rubocop', '~> 1.3'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rb-inotify', '~> 0.9'
  s.add_development_dependency 'rspec', '>= 3.7', '< 4'
  s.add_development_dependency 'rubocop', '~> 0.57.1'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'timecop', '~> 0.5'
end
