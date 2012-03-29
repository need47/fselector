#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  # module version
  VERSION = '0.1.2'
end

ROOT = File.expand_path(File.dirname(__FILE__))

#
# include necessary files
#
require "#{ROOT}/fselector/fileio.rb"
require "#{ROOT}/fselector/util.rb"

#
# base class
Dir.glob("#{ROOT}/fselector/algo_base/*").each do |f|
  require f
end

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

#
# feature selection use an ensemble of algorithms
#
require "#{ROOT}/fselector/ensemble.rb"

