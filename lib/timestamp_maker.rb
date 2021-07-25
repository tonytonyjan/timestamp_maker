# frozen_string_literal: true

require 'pathname'
require 'timestamp_maker/handlers/image_magick'
require 'timestamp_maker/handlers/ffmpeg'
require 'timestamp_maker/mime_recognizers/marcel'
require 'tzinfo'

class TimestampMaker
  COORDINATE_ORIGINS = %w[
    top-left
    top-right
    bottom-left
    bottom-right
  ].freeze

  attr_accessor :mime_recognizer, :handlers

  def initialize(
    mime_recognizer: MimeRecognizers::Marcel.new,
    handlers: [Handlers::ImageMagick.new, Handlers::Ffmpeg.new]
  )
    @mime_recognizer = mime_recognizer
    @handlers = handlers
  end

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
    handler = handlers.find { |i| i.accept?(mime_type) }
    raise "Unsupported MIME type: ##{mime_type}" if handler.nil?

    time = handler.creation_time(input_path) if time.nil?
    raise ArgumentError unless time.is_a?(Time)

    time.localtime(TZInfo::Timezone.get(time_zone)) unless time_zone.nil?

    unless COORDINATE_ORIGINS.include?(coordinate_origin)
      raise(
        ArgumentError,
        "coordinate origin should be one of #{COORDINATE_ORIGINS.join(',')}"
      )
    end

    handler.add_timestamp(
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
