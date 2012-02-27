#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  # module version
  VERSION = '0.1.0'
end

ROOT = File.expand_path(File.dirname(__FILE__))

#
# include necessary files
#
require "#{ROOT}/fselector/fileio.rb"
require "#{ROOT}/fselector/util.rb"

#
# base class
#
require "#{ROOT}/fselector/base.rb"
require "#{ROOT}/fselector/base_discrete.rb"
require "#{ROOT}/fselector/base_continuous.rb"

#
# feature selection use an ensemble of algorithms
#
require "#{ROOT}/fselector/ensemble.rb"

#
# algorithms for handling discrete feature
#
Dir.glob("#{ROOT}/fselector/algo_discrete/*").each do |f|
  require f
end

#
# algorithms for handling continuous feature
#
Dir.glob("#{ROOT}/fselector/algo_continuous/*").each do |f|
  require f
end
