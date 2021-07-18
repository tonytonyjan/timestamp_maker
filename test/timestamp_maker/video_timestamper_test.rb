# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/video_timestamper'

module TimestampMaker
  class VideoTimestamperTest < Minitest::Test
    def test_creation_time
      assert_equal(
        Time.new(2021, 7, 19, 0, 30, 29, 0),
        VideoTimestamper.creation_time(expand_test_file_path('PXL_20210719_003016559.mp4'))
      )
    end
  end
end
