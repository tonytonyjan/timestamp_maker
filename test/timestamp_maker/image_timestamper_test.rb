# frozen_string_literal: true

require 'test_helper'
require 'timestamp_maker/image_timestamper'

module TimestampMaker
  class ImageTimestamperTest < Minitest::Test
    def test_creation_time
      assert_equal(
        Time.new(2021, 7, 3, 13, 1, 48, '+08:00'),
        ImageTimestamper.creation_time(expand_test_file_path('PXL_20210703_050148709.jpg'))
      )
    end
  end
end
