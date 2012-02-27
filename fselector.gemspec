#
# gem specification
#
require File.expand_path(File.dirname(__FILE__) + '/lib/fselector')

Gem::Specification.new do |s|
  s.name             = 'fselector'
  s.version          = FSelector::VERSION
  s.has_rdoc         = 'yard'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.date             = Time.now.strftime('%Y-%m-%d')
  s.summary          = 'feature selection and ranking'
  s.description      = 'a ruby package for feature selection and ranking'
  s.authors          = ['Tiejun Cheng']
  s.email            = 'need47@gmail.com'
  s.require_path     = 'lib'
  s.required_ruby_version = '>= 1.9.0'
  s.files            = %w(README.md LICENSE) + Dir.glob('lib/**/*')
  s.homepage         = 'http://github.com/need47/fselector'
end
