# frozen_string_literal: true

require 'json'
require 'time'
require 'open3'
require 'English'
require 'tzinfo'

module TimestampMaker
  module VideoTimestamper
    class << self
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

        tz =
          case time.zone
          when TZInfo::Timezone then time.zone.name
          when String
            begin
              TZInfo::Timezone.get(time.zone).name
            rescue TZInfo::InvalidTimezoneIdentifier
              time.strftime('%::z').then do |string|
                sign =
                  case string[0]
                  when '+' then '-'
                  when '-' then '+'
                  else raise "Cannot parse time zone: #{string}"
                  end
                "#{sign}#{string[1..-1]}"
              end
            end
          else raise TypeError
          end
        raise "Command failed with exit #{$CHILD_STATUS.exitstatus}: #{command.first}" unless system({ 'TZ' => tz }, *command)
      end

      def creation_time(input_path)
        command = %W[
          ffprobe -v warning -print_format json
          -show_entries format_tags=creation_time,com.apple.quicktime.creationdate
          #{input_path}
        ]
        stdout_string, status = Open3.capture2(*command)
        raise unless status.success?

        parsed = JSON.parse(stdout_string)
        iso8601_string = parsed['format']['tags']['com.apple.quicktime.creationdate'] || parsed['format']['tags']['creation_time']
        raise 'Cannot find creation time' if iso8601_string.nil?

        Time.iso8601(iso8601_string)
      end

      private

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
