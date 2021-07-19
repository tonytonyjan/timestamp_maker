# frozen_string_literal: true

require 'marcel'
require 'pathname'
require 'timestamp_maker/video_timestamper'
require 'timestamp_maker/mime_recognizer'
require 'timestamp_maker/image_timestamper'
require 'tzinfo'

module TimestampMaker
  COORDINATE_ORIGINS = %w[
    top-left
    top-right
    bottom-left
    bottom-right
  ].freeze

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
      background_color: '#000000B3',
      time_zone: nil,
      coordinate_origin: 'top-left',
      x: 32,
      y: 32,
      font_padding: 8
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

      time.localtime(TZInfo::Timezone.get(time_zone)) unless time_zone.nil?

      unless COORDINATE_ORIGINS.include?(coordinate_origin)
        raise ArgumentError, "coordinate origin should be one of #{COORDINATE_ORIGINS.join(',')}"
      end

      processor.add_timestamp(
        input_path, output_path, time,
        format: format,
        font_size: font_size,
        font_family: font_family,
        font_color: font_color,
        background_color: background_color,
        coordinate_origin: coordinate_origin,
        x: x,
        y: y,
        font_padding: font_padding
      )
    end
  end
end
