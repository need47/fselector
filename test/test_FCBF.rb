#
# test Fast Correlation-Based Filter (FCBF) algorithm 
# for selecting discrete feature
#
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


r = FSelector::FCBF.new
r.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + r.get_features.size.to_s

# feature selection
r.select_feature!

# number of features after feature selection
puts '  # features (after): ' + r.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
