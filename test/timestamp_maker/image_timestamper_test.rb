# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/image_timestamper'

module TimestampMaker
  class ImageTimestamperTest < Minitest::Test
    def test_creation_time
      assert_equal(
        Time.new(2020, 10, 26, 15, 53, 45, '+08:00'),
        ImageTimestamper.creation_time(expand_test_file_path('IMG_20201026_155345.jpg'))
      )
    end
  end
end
