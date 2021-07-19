# frozen_string_literal: true

require 'open3'
require 'time'

module TimestampMaker
  module ImageTimestamper
    def self.add_timestamp(input_path, output_path, time, format:, font_size:)
      time_string = time.strftime(format)
      command = %W[
        magick convert #{input_path}
        (
        -background rgba(0,0,0,0.7)
        -fill white
        -font Roboto
        -pointsize #{font_size}
        -gravity NorthWest
        -splice 1x1
        -gravity SouthEast
        -splice 1x1
        label:#{time_string}
        )
        -gravity NorthWest -geometry +32+32 -composite #{output_path}
      ]
      system(*command, exception: true)
    end

    def self.creation_time(input_path)
      command = %W[
        magick identify -format %[exif:DateTime*]%[exif:OffsetTime*] #{input_path}
      ]

      stdout_string, status = Open3.capture2(*command)
      raise unless status.success?

      parsed = Hash[stdout_string.split("\n").map!{ _1[5..].split('=') }]

      time_string = parsed['DateTimeOriginal'] || parsed['DateTimeDigitized'] || parsed['DateTime']
      raise 'Cannot find creation time' if time_string.nil?

      time_offset_string = parsed['OffsetTimeOriginal'] || parsed['OffsetTimeDigitized'] || parsed['OffsetTime'] || 'Z'

      Time.strptime("#{time_string} #{time_offset_string}", '%Y:%m:%d %H:%M:%S %Z')
    end
  end
end
