# frozen_string_literal: true

require 'open3'
require 'time'
require 'English'
require 'tzinfo'

class TimestampMaker
  module Handlers
    class ImageMagick
      GRAVITY_MAP = {
        'top-left' => 'NorthWest',
        'top-right' => 'NorthEast',
        'bottom-left' => 'SouthWest',
        'bottom-right' => 'SouthEast'
      }.freeze

      attr_accessor :time_zone_lookuper

      def initialize(time_zone_lookuper:)
        @time_zone_lookuper = time_zone_lookuper
      end

      def accept?(mime_type)
        mime_type.start_with?('image/')
      end

      def add_timestamp(
        input_path,
        output_path,
        time,
        format:,
        font_size:,
        font_family:,
        font_color:,
        background_color:,
        coordinate_origin:,
        x:,
        y:,
        font_padding:
      )
        time_string = time.strftime(format)
        command = %W[
          convert #{input_path}
          (
          -background #{background_color}
          -fill #{font_color}
          -family #{font_family}
          -pointsize #{font_size}
          -gravity NorthWest
          -splice #{font_padding}x#{font_padding}
          -gravity SouthEast
          -splice #{font_padding}x#{font_padding}
          label:#{time_string}
          )
          -gravity #{GRAVITY_MAP[coordinate_origin]}
          -geometry +#{x}+#{y}
          -composite #{output_path}
        ]
        raise "Command failed with exit #{$CHILD_STATUS.exitstatus}: #{command.first}" unless system(*command)
      end

      def creation_time(input_path)
        command = %W[
          identify -format %[exif:DateTime*]%[exif:OffsetTime*]%[exif:GPSLatitude*]%[exif:GPSLongitude*] #{input_path}
        ]

        stdout_string, status = Open3.capture2(*command)
        raise unless status.success?

        parsed = Hash[stdout_string.split("\n").map! { |i| i[5..-1].split('=') }]

        time_string = parsed['DateTimeOriginal'] || parsed['DateTimeDigitized'] || parsed['DateTime']
        raise 'Cannot find creation time' if time_string.nil?

        time_arguments = time_string.split(/[: ]/).map(&:to_i)

        if (time_zone = retrieve_time_zone_by_coordinate(parsed))
          begin
            return TZInfo::Timezone.get(time_zone).local_time(*time_arguments)
          rescue TZInfo::InvalidTimezoneIdentifier
            warn "Can not find time zone: #{time_zone}"
          end
        end

        time_offset_string = parsed['OffsetTimeOriginal'] || parsed['OffsetTimeDigitized'] || parsed['OffsetTime']
        raise 'Can not find time offset' if time_offset_string.nil?

        Time.new(*time_arguments, time_offset_string)
      end

      private

      def parse_coordinate_number(string)
        degree, minute, second = string.split(', ').map! { |i| Rational(i) }
        (degree + minute / 60 + second / 3600).to_f
      end

      def retrieve_time_zone_by_coordinate(exif)
        unless exif['GPSLatitude'] && exif['GPSLatitudeRef'] && exif['GPSLongitude'] && exif['GPSLongitudeRef']
          return nil
        end

        latitude = parse_coordinate_number(exif['GPSLatitude'])
        latitude = -latitude if exif['GPSLatitudeRef'] == 'S'
        longitude = parse_coordinate_number(exif['GPSLongitude'])
        longitude = -longitude if exif['GPSLongitudeRef'] == 'W'

        time_zone_lookuper.lookup(latitude: latitude, longitude: longitude)
      end
    end
  end
end
