# frozen_string_literal: true

require 'open3'
require 'time'
require 'English'

class TimestampMaker
  module Handlers
    class ImageMagick
      GRAVITY_MAP = {
        'top-left' => 'NorthWest',
        'top-right' => 'NorthEast',
        'bottom-left' => 'SouthWest',
        'bottom-right' => 'SouthEast'
      }.freeze

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
          identify -format %[exif:DateTime*]%[exif:OffsetTime*] #{input_path}
        ]

        stdout_string, status = Open3.capture2(*command)
        raise unless status.success?

        parsed = Hash[stdout_string.split("\n").map! { |i| i[5..-1].split('=') }]

        time_string = parsed['DateTimeOriginal'] || parsed['DateTimeDigitized'] || parsed['DateTime']
        raise 'Cannot find creation time' if time_string.nil?

        time_offset_string = parsed['OffsetTimeOriginal'] || parsed['OffsetTimeDigitized'] || parsed['OffsetTime'] || 'Z'

        Time.strptime("#{time_string} #{time_offset_string}", '%Y:%m:%d %H:%M:%S %z')
      end
    end
  end
end
