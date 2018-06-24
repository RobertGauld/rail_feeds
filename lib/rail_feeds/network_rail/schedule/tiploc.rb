# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      # A class for holding information about a particular tiploc record
      class Tiploc
        include Comparable

        # @!attribute [rw] tiploc
        #   @return [String] The timing point location code.
        # @!attribute [rw] nlc
        #   @return [String] The national location code.
        # @!attribute [rw] nlc_check_char
        # @!attribute [rw] nlc_description
        #   @return [String] Description of location used in CAPRI.
        # @!attribute [rw] tps_description
        #   @return [String] Description of location.
        # @!attribute [rw] stanox
        #   @return [Integer] The TOPS location code.
        # @!attribute [rw] crs
        #   @return [String] The CRS / 3 Alpha code for the location.

        attr_accessor :tiploc, :nlc, :nlc_check_char, :nlc_description,
                      :tps_description, :stanox, :crs

        def initialize(**attributes)
          attributes.each do |attribute, value|
            send "#{attribute}=", value
          end
        end

        # Initialize a new tiploc from a CIF file line
        def self.from_cif(line)
          unless %w[TI TA TD].include?(line[0..1])
            fail ArgumentError, "Invalid line:\n#{line}"
          end

          new(
            tiploc: line[2..8].strip,
            nlc: line[11..16].to_i,
            nlc_check_char: line[17],
            nlc_description: line[56..71].strip,
            tps_description: line[18..43].strip,
            stanox: line[44..48].to_i,
            crs: line[53..55].strip
          )
        end

        def <=>(other)
          hash <=> other&.hash
        end

        def hash
          tiploc.dup
        end

        def to_cif
          format('%-80.80s', [
            'TI',
            format('%-7.7s', tiploc),
            '  ',
            format('%-6.6s', nlc),
            format('%-1.1s', nlc_check_char),
            format('%-26.26s', tps_description),
            format('%-5.5s', stanox),
            '    ',
            format('%-3.3s', crs),
            format('%-16.16s', nlc_description)
          ].join) + "\n"
        end
      end
    end
  end
end
