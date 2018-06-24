# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class Train
        class Location
          # A class for holding information about a particular train's particular location
          class Intermediate < Location
            # @!attribute [rw] line
            #   @return [String]
            # @!attribute [rw] path
            #   @return [String]
            # @!attribute [rw] scheduled_arrival
            #   @return [String] The scheduled time for arriving at the location.
            # @!attribute [rw] scheduled_pass
            #   @return [String] The scheduled time for passing the location.
            # @!attribute [rw] scheduled_departure
            #   @return [String] The sheduled time for departing from the location.
            # @!attribute [rw] public_arrival
            #   @return [String] The public arrival time (HHMM).
            # @!attribute [rw] public_departure
            #   @return [String] The public departure time (HHMM).
            # @!attribute [rw] engineering_allowance
            #   @return [Float] Number of minutes.
            # @!attribute [rw] pathing_allowance
            #   @return [Float] Number of minutes.
            # @!attribute [rw] performance_allowance
            #   @return [Float] Number of minutes.

            attr_accessor :line, :path,
                          :scheduled_arrival, :scheduled_departure, :scheduled_pass,
                          :public_arrival, :public_departure,
                          :engineering_allowance, :pathing_allowance,
                          :performance_allowance

            def initialize(**attributes)
              attributes.each do |attribute, value|
                send "#{attribute}=", value
              end
            end

            # rubocop:disable Metrics/AbcSize
            # rubocop:disable Metrics/MethodLength
            # Initialize a new intermediate location from a CIF file line
            def self.from_cif(line)
              fail ArgumentError, "Invalid line:\n#{line}" unless line[0..1].eql?('LI')

              new(
                tiploc: line[2..8].strip,
                tiploc_suffix: line[9].to_i,
                scheduled_arrival: line[10..14].strip,
                scheduled_departure: line[15..19].strip,
                scheduled_pass: line[20..24].strip,
                public_arrival: line[25..28].strip,
                public_departure: line[29..32].strip,
                platform: line[33..35].strip,
                line: line[36..38].strip,
                path: line[39..41].strip,
                activity: line[42..53].strip,
                engineering_allowance: parse_allowance(line[54..55].strip),
                pathing_allowance: parse_allowance(line[56..57].strip),
                performance_allowance: parse_allowance(line[58..59].strip)
              )
            end
            # rubocop:enable Metrics/AbcSize
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/AbcSize
            # rubocop:disable Metrics/MethodLength
            def to_cif
              format('%-80.80s', [
                'LI',
                format('%-7.7s', tiploc),
                format('%-1.1s', tiploc_suffix),
                format('%-5.5s', scheduled_arrival),
                format('%-5.5s', scheduled_departure),
                format('%-5.5s', scheduled_pass),
                format('%-4.4s', public_arrival),
                format('%-4.4s', public_departure),
                format('%-3.3s', platform),
                format('%-3.3s', line),
                format('%-3.3s', path),
                format('%-12.12s', activity),
                format('%-2.2s', allowance_cif(engineering_allowance)),
                format('%-2.2s', allowance_cif(pathing_allowance)),
                format('%-2.2s', allowance_cif(performance_allowance))
              ].join) + "\n"
            end
            # rubocop:enable Metrics/AbcSize
            # rubocop:enable Metrics/MethodLength
          end
        end
      end
    end
  end
end
