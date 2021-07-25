# frozen_string_literal: true

class TimestampMaker
  module TimeZoneLookupers
    class Mock
      def initialize(time_zone)
        @time_zone = time_zone
      end

      def lookup(*)
        @time_zone
      end
    end
  end
end
