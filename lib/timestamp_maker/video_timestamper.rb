# frozen_string_literal: true

require 'json'
require 'time'
require 'open3'

module TimestampMaker
  module VideoTimestamper
    def self.add_timestamp(input_path, output_path, time, format:)
      creation_timestamp = time.to_i
      text = "%{pts:localtime:#{creation_timestamp}:#{escape_text_expansion_argument(format)}}"
      drawtext = %W[
        x=32
        y=32
        font=Roboto
        fontsize=32
        fontcolor=white
        box=1
        boxcolor=black@0.7
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

    def self.creation_time(input_path)
      command = %W[
        ffprobe -v warning -print_format json -show_entries format_tags=creation_time #{input_path}
      ]
      stdout_string, status = Open3.capture2(*command)
      raise unless status.success?

      parsed = JSON.parse(stdout_string)
      iso8601_string = parsed['format']['tags']['creation_time']
      raise 'Cannot find creation time' if iso8601_string.nil?

      Time.iso8601(iso8601_string)
    end

    def self.escape_text_expansion_argument(string)
      string.gsub(/[:{}]/, '\\\\\\&')
    end

    def self.escape_filter_description_value(string)
      string.gsub(/[:\\']/, '\\\\\\&')
    end

    def self.escape_filter_description(string)
      string.gsub(/[\\'\[\],;]/, '\\\\\\&')
    end
  end
end
