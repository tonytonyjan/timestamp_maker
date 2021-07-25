# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/handlers/image_magick'
require 'tempfile'

class TimestampMaker
  module Handlers
    class ImageMagickTest < Minitest::Test
      def test_add_timestamp_would_not_raise_error
        Tempfile.open do |output_file|
          ImageMagick.new.add_timestamp(
            expand_test_file_path('IMG_20201026_155345.jpg'),
            output_file.path,
            Time.at(0),
            format: '%Y-%m-%d %H:%M:%S',
            font_size: 32,
            font_family: 'Sans',
            font_color: 'white',
            background_color: '#000000B3',
            coordinate_origin: 'top-left',
            x: 32,
            y: 32,
            font_padding: 8,
          )
        end
      end

      def test_creation_time
        assert_equal(
          Time.new(2020, 10, 26, 15, 53, 45, '+08:00'),
          ImageMagick.new.creation_time(expand_test_file_path('IMG_20201026_155345.jpg'))
        )
      end
    end
  end
end
