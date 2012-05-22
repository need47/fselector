# access to the statistical routines in R package
require 'rinruby'
R.eval 'options(warn = -1)' # suppress R warnings

#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  # module version
  VERSION = '1.3.0'
end

# the root dir of FSelector
ROOT = File.expand_path(File.dirname(__FILE__))

#
# include necessary files
#
# read and write file, supported formats include CSV, LibSVM and WEKA files
require "#{ROOT}/fselector/fileio.rb"
# extend Array and String class
require "#{ROOT}/fselector/util.rb"
# check data consistency
require "#{ROOT}/fselector/consistency.rb"
# entropy-related functions
require "#{ROOT}/fselector/entropy.rb"
# normalization for continuous data
require "#{ROOT}/fselector/normalizer.rb"
# discretization for continuous data
require "#{ROOT}/fselector/discretizer.rb"
# replace missing values
require "#{ROOT}/fselector/replace_missing_values.rb"

#
# base class
#
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
# algorithms for handling both discrete and continuous feature
#
Dir.glob("#{ROOT}/fselector/algo_both/*").each do |f|
  require f
end


#
# feature selection use an ensemble of algorithms
#
require "#{ROOT}/fselector/ensemble.rb"

