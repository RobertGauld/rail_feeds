# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      module Header
        # A class to hole the information from the header row of a cif file
        class CIF
          # @!attribute [rw] file_identity
          # @!attribute [rw] extracted_at
          #   @return [Time] When the BTD extract happened.
          # @!attribute [rw] current_file_reference
          #   @return [String] Unique reference for the current file.
          # @!attribute [rw] previous_file_reference
          #   @return [String, nil] Unique reference for the previous file
          #   (the one to apply the update to).
          # @!attribute [rw] update_indicator
          #   @return [String] 'F' for a full extract, 'U' for an update extract.
          # @!attribute [rw] version
          #   @return [String] The version of the software that generated the CIF file.
          # @!attribute [rw] start_date
          #   @return [Date]
          # @!attribute [rw] end_date
          #   @return [Date]

          attr_accessor :file_identity, :extracted_at,
                        :current_file_reference, :previous_file_reference,
                        :update_indicator, :version, :start_date, :end_date

          def initialize(**attributes)
            attributes.each do |attribute, value|
              send "#{attribute}=", value
            end
          end

          # rubocop:disable Metrics/AbcSize
          # Initialize a new header from a CIF file line
          def self.from_cif(line)
            fail ArgumentError, "Invalid line:\n#{line}" unless line[0..1].eql?('HD')

            new(
              file_identity: line[2..21].strip,
              extracted_at: Time.strptime(line[22..31] + 'UTC', '%d%m%y%H%M%Z'),
              current_file_reference: line[32..38].strip,
              previous_file_reference: line[39..45].strip,
              update_indicator: line[46].strip,
              version: line[47].strip,
              start_date: Date.strptime(line[48..53], '%d%m%y'),
              end_date: Date.strptime(line[54..59], '%d%m%y')
            )
          end
          # rubocop:enable Metrics/AbcSize

          # Test if this is a header for an update file
          def update?
            update_indicator.eql?('U')
          end

          # Test if this is a header for a full file
          def full?
            update_indicator.eql?('F')
          end

          def ==(other)
            hash == other&.hash
          end

          def hash
            current_file_reference&.dup
          end

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Style/FormatStringToken
          def to_cif
            format('%-80.80s', [
              'HD',
              format('%-20.20s', file_identity),
              format('%-10.10s', extracted_at&.strftime('%d%m%y%H%M')),
              format('%-7.7s', current_file_reference),
              format('%-7.7s', previous_file_reference),
              format('%-1.1s', update_indicator),
              format('%-1.1s', version),
              format('%-6.6s', start_date&.strftime('%d%m%y')),
              format('%-6.6s', end_date&.strftime('%d%m%y'))
            ].join) + "\n"
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Style/FormatStringToken

          def to_s
            "File #{file_identity.inspect} (version #{version}) " \
              "at #{extracted_at.strftime('%Y-%m-%d %H:%M')}. " \
              "#{full? ? 'A full' : 'An update'} extract " \
              "for #{start_date} to #{end_date}."
          end
        end
      end
    end
  end
end
