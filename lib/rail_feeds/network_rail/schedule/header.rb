# frozen_string_literal: true

require_relative 'header/cif'
require_relative 'header/json'

module RailFeeds
  module NetworkRail
    module Schedule
      module Header # :nodoc:
        # Initialize a new header from a CIF file line
        def self.from_cif(line)
          CIF.from_cif line
        end

        # Initialize a new header from a JSON file line
        def self.from_json(line)
          JSON.from_json line
        end
      end
    end
  end
end
