# frozen_string_literal: true

require 'minitest/autorun'

class Minitest::Test
  parallelize_me!

  def open_test_file(filename, *args, **keys, &block)
    File.open("#{__dir__}/files/#{filename}", *args, **keys, &block)
  end

  def expand_test_file_path(filename)
    "#{__dir__}/files/#{filename}"
  end
end
