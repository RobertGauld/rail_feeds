module RailFeeds
  module NetworkRail
    # A Class to store username & password required to access network rail feeds
    # Can be used to set a global default but create new instances with
    # specific ones for a specific use.
    class Credentials < RailFeeds::Credentials
      def to_a
        [username, password]
      end

      def self.to_a
        [username, password]
      end
    end
  end
end
