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
  s.authors          = ['Tiejun Cheng']
  s.email            = 'need47@gmail.com'
  s.require_path     = 'lib'
  s.required_ruby_version = '>= 1.9.0'
  s.files            = %w(README.md LICENSE) + Dir.glob('lib/**/*')
  s.homepage         = 'http://github.com/need47/fselector'
  s.description      = "FSelector is a Ruby gem for feature selection and ranking. It aims to integrate various feature selection/ranking algorithms into one single package. You're highly welcomed and encouraged to contact me if you want to contribute and/or add your own feature selection algorithms. FSelector enables the user to perform feature selection by using either a single algorithm or an ensemble of algorithms. FSelector acts on a full-feature data set and outputs a reduced data set with only selected features, which can later be used as the input for various machine learning softwares including LibSVM and WEKA. FSelector, itself, does not implement any of the machine learning algorithms such as support vector machines and random forest. Below is a summary of FSelector's features."
end
