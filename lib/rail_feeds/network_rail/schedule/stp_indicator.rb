# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      # A collection of methods for working with Short Term Planning indicators.
      # Provides an stp_indicator attribute to the class.
      module STPIndicator
        STP_CIF_MAP = [
          [:permanent, 'P'],
          [:stp_new, 'N'],
          [:stp_overlay, 'O'],
          [:stp_cancellation, 'C']
        ].freeze
        private_constant :STP_CIF_MAP

        def self.included(base)
          base.extend ClassMethods
        end

        # @return [Symbol, nil] Whether (and what kind) of STP record this is:
        # * :permanent - This is a permanent (not STP) record
        # * :stp_new - This is a new record (not an overlay)
        # * :stp_overlay - This record should be overlayed on the permanent one
        # * :stp_cancellation - This is an STP cancellation of the permanaent record
        def stp_indicator
          @stp_indicator ||= ' '
        end

        # @param [Symbol, #to_s] value Whether (and what kind) of STP record this is:
        # * :permanent, 'P' - This is a permanent (not STP) record
        # * :stp_new, 'N' - This is a new record (not an overlay)
        # * :stp_overlay, 'O' - This record should be overlayed on the permanent one
        # * :stp_cancellation, 'C' - This is an STP cancellation of the permanaent record
        def stp_indicator=(value)
          if STP_CIF_MAP.map(&:last).include?(value.to_s)
            # Convert String / to_s value to relevant Symbol
            value = stp_indicator_from_cif(value)
          end

          unless STP_CIF_MAP.map(&:first).include?(value)
            fail ArgumentError, "value (#{value.inspect}) is invalid, must be any of: " +
                                STP_CIF_MAP.flatten.map(&:inspect).join(', ')
          end

          @stp_indicator = value
        end

        protected

        def stp_indicator_to_cif
          self.class.stp_indicator_to_cif stp_indicator
        end

        def stp_indicator_from_cif(value)
          self.class.stp_indicator_from_cif(value)
        end

        module ClassMethods # :nodoc:
          def stp_indicator_to_cif(value)
            STP_CIF_MAP.find { |i| i.first.eql?(value) }&.last
          end

          def stp_indicator_from_cif(value)
            STP_CIF_MAP.find { |i| i.last.eql?(value) }&.first || ' '
          end
        end
        private_constant :ClassMethods
      end
    end
  end
end
