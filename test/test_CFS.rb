#
# test the Correlation-based Feature Selection (CFS) algorithm
# for selecting continuous feature (use Iris data set) and
# for selecting discrete feature (use SPECT data set)
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

puts "  test for continuous feature"

r1 = FSelector::CFS_c.new # CFS_c is for continuous feature
r1.data_from_csv('test/iris.csv')

# number of features before feature selection
puts '  # features (before): ' + r1.get_features.size.to_s

# feature selection
r1.select_feature!

# number of features after feature selection
puts '  # features (after): ' + r1.get_features.size.to_s

puts "\n  test for discrete feature" 

r2 = FSelector::CFS_d.new # CFS_d is for discrete feature
r2.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + r2.get_features.size.to_s

# feature selection
r2.select_feature!

# number of features after feature selection
puts '  # features (after): ' + r2.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
