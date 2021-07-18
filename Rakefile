# frozen_string_literal: true

task default: :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = Dir['test/**/*_test.rb']
end

require 'rubygems/package_task'
spec = Gem::Specification.load(File.expand_path('timestamp_maker.gemspec', __dir__))
Gem::PackageTask.new(spec).define
