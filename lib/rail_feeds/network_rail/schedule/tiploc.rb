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
        # @!attribute [rw] nlc_description
        #   @return [String] Description of location used in CAPRI.
        # @!attribute [rw] tps_description
        #   @return [String] Description of location.
        # @!attribute [rw] stanox
        #   @return [Integer] The TOPS location code.
        # @!attribute [rw] crs
        #   @return [String] The CRS / 3 Alpha code for the location.

        attr_accessor :tiploc, :nlc, :nlc_description, :tps_description, :stanox, :crs

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
            nlc: Schedule.nil_or_i(line[11..16]),
            nlc_description: line[56..71].strip,
            tps_description: line[18..43].strip,
            stanox: Schedule.nil_or_i(line[44..48]),
            crs: line[53..55].strip
          )
        end

        # Initialize a new tiploc from a JSON file line
        def self.from_json(line)
          data = ::JSON.parse(line)['TiplocV1']

          new(
            tiploc: data['tiploc_code'],
            nlc: Schedule.nil_or_i(data['nalco']),
            stanox: Schedule.nil_or_i(data['stanox']),
            crs: data['crs_code'],
            nlc_description: Schedule.nil_or_strip(data['description']),
            tps_description: data['tps_description']
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
            ' ',
            format('%-26.26s', tps_description),
            format('%-5.5s', stanox),
            '    ',
            format('%-3.3s', crs),
            format('%-16.16s', nlc_description)
          ].join) + "\n"
        end

        def to_json(**opts)
          {
            'TiplocV1' => {
              'transaction_type' => 'Create',
              'tiploc_code' => tiploc,
              'nalco' => nlc.to_s,
              'stanox' => stanox.to_s,
              'crs_code' => crs,
              'description' => nlc_description,
              'tps_description' => tps_description
            }
          }.to_json(**opts)
        end
      end
    end
  end
end
