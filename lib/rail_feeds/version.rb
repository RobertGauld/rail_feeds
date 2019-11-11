# frozen_string_literal: true

module RailFeeds
  # Holds information on the current gem version.
  class Version
    MAJOR = 0
    MINOR = 0
    PATCH = 4

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
