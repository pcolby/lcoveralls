Gem::Specification.new do |spec|
  spec.author      = 'Paul Colby'
  spec.date        = '2010-04-28'
  spec.description = 'Lcoveralls is a simple script for reporting code coverage results from LCOV to Coveralls.'
  spec.email       = 'ruby@colby.id.au'
  spec.executables = [ 'lcoveralls' ]
  spec.files       = Dir['lib/*.rb'] + Dir['lib/lcoveralls/*.rb']
  spec.homepage    = 'https://github.com/pcolby/lcoveralls'
  spec.license     = 'Apache-2.0'
  spec.name        = 'lcoveralls'
  spec.summary     = 'Report Gcov / LCOV (ie C, C++, Go, etc) code coverage to coveralls.io'
  spec.version     = '0.1.0'
end
