# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'timestamp_maker'
  s.version     = '1.0.0'
  s.licenses    = ['MIT']
  s.summary     = 'timestamp_maker adds timestamp to images and videos.'
  s.description = 'timestamp_maker adds timestamp to images and videos.'
  s.authors     = ['Weihang Jian']
  s.email       = 'tonytonyjan@gmail.com'
  s.files       = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.executables << 'timestamp'
  s.metadata    = { 'source_code_uri' => 'https://github.com/tonytonyjan/timestamp_maker' }
  s.add_runtime_dependency 'marcel', '~> 1.0'
  s.add_development_dependency 'minitest', '~> 5.14'
  s.add_development_dependency 'rake', '~> 13.0'
end
