# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/video_timestamper'
require 'tempfile'

module TimestampMaker
  class VideoTimestamperTest < Minitest::Test
    def test_add_timestamp_would_not_raise_error
      Tempfile.open(['', '.mp4']) do |output_file|
        VideoTimestamper.add_timestamp(
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
          font_padding: 8,
        )
      end
    end

    def test_creation_time
      assert_equal(
        Time.new(2021, 7, 19, 0, 30, 29, 0),
        VideoTimestamper.creation_time(expand_test_file_path('PXL_20210719_003016559.mp4'))
      )
    end
  end
end
