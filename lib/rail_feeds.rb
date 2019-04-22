# frozen_string_literal: true

module RailFeeds # :nodoc:
end

require 'date'
require 'forwardable'
require 'logger'

require 'nokogiri'
require 'stomp'

require 'zeitwerk'
class MyInflector < Zeitwerk::Inflector # :nodoc:
  def camelize(basename, _abspath)
    case basename
    when 'stp_indicator' then 'STPIndicator'
    when 'http_client' then 'HTTPClient'
    when 'cif' then 'CIF'
    when 'json' then 'JSON'
    else
      super
    end
  end
end
loader = Zeitwerk::Loader.for_gem
loader.inflector = MyInflector.new
loader.setup
loader.logger = RailFeeds::Logging.logger
loader.eager_load
