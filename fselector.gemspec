#
# gem specification
#
require File.expand_path(File.dirname(__FILE__) + '/lib/fselector')

Gem::Specification.new do |s|
  s.name             = 'fselector'
  s.version          = FSelector::VERSION
  s.has_rdoc         = 'yard'
  s.date             = Time.now.strftime('%Y-%m-%d')
  s.summary          = 'FSelector: a Ruby gem for feature selection'
  s.authors          = ['Tiejun Cheng']
  s.email            = 'need47@gmail.com'
  s.require_path     = 'lib'
  s.required_ruby_version = '>= 1.9.0'
  s.add_dependency('rinruby', '>= 2.0.2')
  s.files            = ['README.md', 'ChangeLog', 'LICENSE', 'HowToContribute', '.yardopts'] + Dir.glob('lib/**/*')
  s.homepage         = 'http://github.com/need47/fselector'
  s.description      = 'FSelector is a Ruby gem that aims to integrate various feature selection algorithms and related functions into one single package. Welcome to contact me (need47@gmail.com) if you want to contribute your own algorithms or report a bug. FSelector allows user to perform feature selection by using either a single algorithm or an ensemble of multiple algorithms, and other common tasks including normalization and discretization on continuous data, as well as replace missing feature values with certain criterion. FSelector acts on a full-feature data set in either CSV, LibSVM or WEKA file format and outputs a reduced data set with only selected subset of features, which can later be used as the input for various machine learning softwares such as LibSVM and WEKA. FSelector, as a collection of filter methods, does not implement any classifier like support vector machines or random forest.'
end
