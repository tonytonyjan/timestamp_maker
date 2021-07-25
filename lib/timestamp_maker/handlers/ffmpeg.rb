# frozen_string_literal: true

require 'json'
require 'time'
require 'open3'
require 'English'
require 'tzinfo'

class TimestampMaker
  module Handlers
    class Ffmpeg

      attr_accessor :time_zone_lookuper

      def initialize(time_zone_lookuper:)
        @time_zone_lookuper = time_zone_lookuper
      end

      def accept?(mime_type)
        mime_type.start_with?('video/')
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
        creation_timestamp = time.to_i
        text = "%{pts:localtime:#{creation_timestamp}:#{escape_text_expansion_argument(format)}}"
        drawtext = +"#{coord_map(coordinate_origin, x, y)}:" << %W[
          font=#{escape_filter_description_value(font_family)}
          fontsize=#{font_size}
          fontcolor=#{font_color}
          box=1
          boxcolor=#{background_color}
          boxborderw=#{font_padding}
          text=#{escape_filter_description_value(text)}
        ].join(':')

        command = %W[
          ffmpeg -y
          -v warning
          -i #{input_path}
          -map_metadata 0
          -vf drawtext=#{escape_filter_description(drawtext)}
          #{output_path}
        ]

        tz = tz_env_string(time)
        raise "Command failed with exit #{$CHILD_STATUS.exitstatus}: #{command.first}" unless system({ 'TZ' => tz },
                                                                                                     *command)
      end

      def creation_time(input_path)
        command = %W[
          ffprobe -v warning -print_format json
          -show_entries format_tags=creation_time,com.apple.quicktime.creationdate,location
          #{input_path}
        ]
        stdout_string, status = Open3.capture2(*command)
        raise unless status.success?

        parsed = JSON.parse(stdout_string)
        iso8601_string = parsed['format']['tags']['com.apple.quicktime.creationdate'] || parsed['format']['tags']['creation_time']
        raise 'Cannot find creation time' if iso8601_string.nil?

        time = Time.iso8601(iso8601_string)

        iso6709_string = parsed['format']['tags']['location']
        if iso6709_string && (time_zone = retrieve_time_zone_from_iso6709(iso6709_string))
          begin
            return Time.at(time, in: TZInfo::Timezone.get(time_zone))
          rescue TZInfo::InvalidTimezoneIdentifier
            warn "Can not find time zone: #{time_zone}"
          end
        end

        time
      end

      private

      def retrieve_time_zone_from_iso6709(string)
        data = string.match(/([+-]\d*\.?\d*)([+-]\d*\.?\d*)/)
        latitude = data[1].to_f
        longitude = data[2].to_f
        time_zone_lookuper.lookup(latitude: latitude, longitude: longitude)
      end

      def tz_env_string(time)
        return time.zone.name if time.zone.is_a? TZInfo::Timezone

        TZInfo::Timezone.get(time.zone).name
      rescue TZInfo::InvalidTimezoneIdentifier
        offset = time.utc_offset
        tz_string = "#{offset / 3600}:#{offset % 3600 / 16}:#{offset % 60}"
        return "+#{tz_string}" if offset.negative?

        "-#{tz_string}"
      end

      def coord_map(coordinate_origin, x, y)
        case coordinate_origin
        when 'top-left' then "x=#{x}:y=#{y}"
        when 'top-right' then "x=w-tw-#{x}:y=#{y}"
        when 'bottom-left' then "x=#{x}:y=h-th-#{y}"
        when 'bottom-right' then "x=w-tw-#{x}:y=h-th-#{y}"
        end
      end

      def escape_text_expansion_argument(string)
        string.gsub(/[:{}]/, '\\\\\\&')
      end

      def escape_filter_description_value(string)
        string.gsub(/[:\\']/, '\\\\\\&')
      end

      def escape_filter_description(string)
        string.gsub(/[\\'\[\],;]/, '\\\\\\&')
      end
    end
  end
end
