# frozen_string_literal: true

require 'minitest/autorun'

class Minitest::Test
  parallelize_me!

  def open_test_file(filename, ...)
    File.open("#{__dir__}/files/#{filename}", ...)
  end

  def expand_test_file_path(filename)
    "#{__dir__}/files/#{filename}"
  end
end
