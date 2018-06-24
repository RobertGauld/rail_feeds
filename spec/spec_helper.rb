# frozen_string_literal: true

require 'yaml'

require 'simplecov'
SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
SimpleCov.start do
  add_filter 'spec/'
end

require 'coveralls'
Coveralls.wear! if ENV['TRAVIS']

RSPEC_ROOT = File.dirname __FILE__
RSPEC_FIXTURES = File.join RSPEC_ROOT, 'fixtures'
Dir[File.join(RSPEC_ROOT, '**', '*_shared.rb')].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec  do |configuration|
    # Using the expect syntax is preferable to the should syntax in some cases.
    # The problem here is that the :should syntax that RSpec uses can fail in
    # the case of proxy objects, and objects that include the delegate module.
    # Essentially it requires that we define methods on every object in the
    # system. Not owning every object means that we cannot ensure this works in
    # a consistent manner. The expect syntax gets around this problem by not
    # relying on RSpec specific methods being defined on every object in the
    # system.
    # configuration.syntax = [:expect, :should]
    configuration.syntax = :expect
  end
end

require 'rail_feeds'
