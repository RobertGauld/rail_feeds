# frozen_string_literal: true

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
