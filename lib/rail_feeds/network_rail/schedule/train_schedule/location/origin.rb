# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class TrainSchedule
        class Location
          # A class for holding information about a particular train's origin location
          class Origin < Location
            # @!attribute [rw] line
            #   @return [String]
            # @!attribute [rw] scheduled_departure
            #   @return [String] The sheduled time for departing from the location.
            # @!attribute [rw] public_departure
            #   @return [String] The public departure time (HHMM).
            # @!attribute [rw] engineering_allowance
            #   @return [Float] Number of minutes.
            # @!attribute [rw] pathing_allowance
            #   @return [Float] Number of minutes.
            # @!attribute [rw] performance_allowance
            #   @return [Float] Number of minutes.

            attr_accessor :scheduled_departure, :public_departure, :line,
                          :engineering_allowance, :pathing_allowance,
                          :performance_allowance

            def initialize(**attributes)
              attributes.each do |attribute, value|
                send "#{attribute}=", value
              end
            end

            # rubocop:disable Metrics/AbcSize
            # Initialize a new origin location from a CIF file line
            def self.from_cif(line)
              fail ArgumentError, "Invalid line:\n#{line}" unless line[0..1].eql?('LO')

              new(
                tiploc: line[2..8].strip,
                tiploc_suffix: line[9].to_i,
                scheduled_departure: line[10..14].strip,
                public_departure: line[15..18].strip,
                platform: line[19..21].strip,
                line: line[22..24].strip,
                activity: line[29..40].strip,
                engineering_allowance: parse_allowance(line[25..26].strip),
                pathing_allowance: parse_allowance(line[27..28].strip),
                performance_allowance: parse_allowance(line[41..42].strip)
              )
            end
            # rubocop:enable Metrics/AbcSize

            # rubocop:disable Metrics/AbcSize
            def to_cif
              format('%-80.80s', [
                'LO',
                format('%-7.7s', tiploc),
                format('%-1.1s', tiploc_suffix),
                format('%-5.5s', scheduled_departure),
                format('%-4.4s', public_departure),
                format('%-3.3s', platform),
                format('%-3.3s', line),
                format('%-2.2s', allowance_cif(engineering_allowance)),
                format('%-2.2s', allowance_cif(pathing_allowance)),
                format('%-12.12s', activity),
                format('%-2.2s', allowance_cif(performance_allowance))
              ].join) + "\n"
            end
            # rubocop:enable Metrics/AbcSize
          end
        end
      end
    end
  end
end
