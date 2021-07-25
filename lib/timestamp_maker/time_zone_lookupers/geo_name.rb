# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class TimestampMaker
  module TimeZoneLookupers
    ENDPOINT = URI.parse('http://api.geonames.org/timezoneJSON')

    class GeoName
      attr_accessor :username

      def initialize(username:)
        @username = username
      end

      def lookup(latitude:, longitude:)
        query = URI.encode_www_form(
          [['lat', latitude], ['lng', longitude], ['username', username]]
        )
        response = Net::HTTP.get_response(URI.parse("#{ENDPOINT}?#{query}"))
        raise "Got HTTP status code: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        parsed = JSON.parse(response.body)
        parsed['timezoneId']
      end
    end
  end
end
