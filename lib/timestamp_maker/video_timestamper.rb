# frozen_string_literal: true

require 'json'
require 'time'
require 'open3'

module TimestampMaker
  module VideoTimestamper
    class << self
      def add_timestamp(input_path, output_path, time, format:, font_size:, font_family:, font_color:, background_color:)
        creation_timestamp = time.to_i
        text = "%{pts:localtime:#{creation_timestamp}:#{escape_text_expansion_argument(format)}}"
        drawtext = %W[
          x=32
          y=32
          font=#{escape_filter_description_value(font_family)}
          fontsize=#{font_size}
          fontcolor=#{font_color}
          box=1
          boxcolor=#{background_color}
          boxborderw=8
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

        system(*command, exception: true)
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
