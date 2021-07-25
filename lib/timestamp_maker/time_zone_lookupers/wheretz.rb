# frozen_string_literal: true

require 'wheretz'
require 'json' # wheretz forgets to require json

class TimestampMaker
  module TimeZoneLookupers
    class Wheretz
      def lookup(latitude:, longitude:)
        case result = WhereTZ.lookup(latitude, longitude)
        when String then result
        when Array then result.first
        else raise 'Something went wrong with WhereTZ'
        end
      end
    end
  end
end
