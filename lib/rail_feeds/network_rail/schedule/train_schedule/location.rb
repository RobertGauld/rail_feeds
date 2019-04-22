# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class TrainSchedule
        # A class for holding information about a particular train's particular location.
        class Location
          # @!attribute [rw] tiploc
          #   @return [String] The location where the change occurs.
          # @!attribute [rw] tiploc_suffix
          #   @return [String]
          # @!attribute [rw] platform
          #   @return [String]
          # @!attribute [rw] activity
          #   @return [String]

          attr_accessor :tiploc, :tiploc_suffix, :platform, :activity

          def initialize
            fail 'This class should never be instantiated'
          end

          # Initialize a new location from a CIF file line
          # (will be of the appropriate sub class)
          def self.from_cif(line)
            case line[0..1]
            when 'LO'
              Origin.from_cif line
            when 'LI'
              Intermediate.from_cif line
            when 'LT'
              Terminating.from_cif line
            else
              fail ArgumentError, "Improper line type #{line[0..1]}: #{line}"
            end
          end

          def ==(other)
            hash == other&.hash
          end

          def hash
            "#{tiploc}-#{tiploc_suffix}"
          end

          private

          def self.parse_allowance(value)
            half = value[-1].eql?('H')
            value = value.to_f
            half ? value + 0.5 : value
          end
          private_class_method :parse_allowance

          def allowance_cif(value)
            i = value.to_i
            f = value.to_f - i
            f.eql?(0.5) ? "#{i}H" : i.to_s
          end

          def allowance_json(value)
            return nil if value.nil?
            i = value.to_i
            f = value.to_f - i
            f.eql?(0.5) ? "#{i}H" : i.to_s
          end
        end
      end
    end
  end
end
