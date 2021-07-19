# frozen_string_literal: true

require 'marcel'
require 'pathname'
require 'timestamp_maker/video_timestamper'
require 'timestamp_maker/mime_recognizer'
require 'timestamp_maker/image_timestamper'

module TimestampMaker
  @mime_recognizer = MimeRecognizer
  @image_timestamper = ImageTimestamper
  @video_timestamper = VideoTimestamper

  class << self
    attr_reader :mime_recognizer, :image_timestamper, :video_timestamper

    def add_timestamp(
      input_path, output_path,
      format: '%Y-%m-%d %H:%M:%S',
      time: nil,
      font_size: 32,
      font_family: 'Sans',
      font_color: 'white',
      background_color: '#000000B3'
    )
      mime_type = mime_recognizer.recognize(input_path)
      processor =
        case mime_type.split('/').first
        when 'image' then image_timestamper
        when 'video' then video_timestamper
        else raise "Unsupported MIME type: ##{mime_type}"
        end
      time = processor.creation_time(input_path) if time.nil?
      raise ArgumentError unless time.is_a?(Time)

      processor.add_timestamp(
        input_path, output_path, time,
        format: format,
        font_size: font_size,
        font_family: font_family,
        font_color: font_color,
        background_color: background_color
      )
    end
  end
end
