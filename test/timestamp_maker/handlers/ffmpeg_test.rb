# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/handlers/ffmpeg'
require 'tempfile'

class TimestampMaker
  module Handlers
    class FfmpegTest < Minitest::Test
      def test_add_timestamp_would_not_raise_error
        Tempfile.open(['', '.mp4']) do |output_file|
          Ffmpeg.new.add_timestamp(
            expand_test_file_path('PXL_20210719_003016559.mp4'),
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
            font_padding: 8
          )
        end
      end

      def test_add_timestamp_would_not_raise_error_when_time_zone_is_nil
        # There is no document about why Time#zone could be nil,
        # but we should still able to handle this case.
        time = Time.at(0)
        time.stub :zone, nil do
          Tempfile.open(['', '.mp4']) do |output_file|
            Ffmpeg.new.add_timestamp(
              expand_test_file_path('PXL_20210719_003016559.mp4'),
              output_file.path,
              time,
              format: '%Y-%m-%d %H:%M:%S',
              font_size: 32,
              font_family: 'Sans',
              font_color: 'white',
              background_color: '#000000B3',
              coordinate_origin: 'top-left',
              x: 32,
              y: 32,
              font_padding: 8
            )
          end
        end
      end

      def test_creation_time
        assert_equal(
          Time.new(2021, 7, 19, 0, 30, 29, 0),
          Ffmpeg.new.creation_time(expand_test_file_path('PXL_20210719_003016559.mp4'))
        )
      end
    end
  end
end
