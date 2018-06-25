# frozen_string_literal: true

require_relative 'schedule/days'
require_relative 'schedule/stp_indicator'
require_relative 'schedule/association'
require_relative 'schedule/header'
require_relative 'schedule/tiploc'
require_relative 'schedule/train'
require_relative 'schedule/fetcher'
require_relative 'schedule/parser'
require_relative 'schedule/data'

module RailFeeds
  module NetworkRail
    module Schedule # :nodoc:
      def self.nil_or_i(value)
        return nil if value.to_s.strip.empty?
        value.to_i
      end

      def self.nil_or_strip(value)
        return nil if value.to_s.strip.empty?
        value.strip
      end

      def self.make_date(value, allow_nil: false)
        return nil if allow_nil && value.strip.empty?
        return Date.new(9999, 12, 31) if value.eql?('999999')
        Date.strptime(value, '%y%m%d')
      end
    end
  end
end
