# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class TrainSchedule
        class Location
          # A class for holding info about a particular train's terminating location
          class Terminating < Location
            # @!attribute [rw] path
            #   @return [String]
            # @!attribute [rw] scheduled_arrival
            #   @return [String] The scheduled time for arriving at the location.
            # @!attribute [rw] public_arrival
            #   @return [String] The public arrival time (HHMM).

            attr_accessor :scheduled_arrival, :public_arrival, :path

            def initialize(**attributes)
              attributes.each do |attribute, value|
                send "#{attribute}=", value
              end
            end

            # rubocop:disable Metrics/AbcSize
            # Initialize a new terminating from a CIF file line
            def self.from_cif(line)
              fail ArgumentError, "Invalid line:\n#{line}" unless line[0..1].eql?('LT')

              new(
                tiploc: line[2..8].strip,
                tiploc_suffix: line[9].to_i,
                scheduled_arrival: line[10..14].strip,
                public_arrival: line[15..18].strip,
                platform: line[19..21].strip,
                path: line[22..24].strip,
                activity: line[25..36].strip
              )
            end
            # rubocop:enable Metrics/AbcSize

            def to_cif
              format('%-80.80s', [
                'LT',
                format('%-7.7s', tiploc),
                format('%-1.1s', tiploc_suffix),
                format('%-5.5s', scheduled_arrival),
                format('%-4.4s', public_arrival),
                format('%-3.3s', platform),
                format('%-3.3s', path),
                format('%-12.12s', activity)
              ].join) + "\n"
            end
          end
        end
      end
    end
  end
end
