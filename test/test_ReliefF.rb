#
# test ReliefF algorithm
# for selecting continuous feature (use randomly generated data) and 
# for selecting discrete feature (use randomly generated data)
#
# note ReliefF algorithm applicable to multi-class problem 
# with missing feature values
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


puts "  test for continuous feature"

r1 = FSelector::ReliefF_c.new # ReliefF_c is for continuous feature

# read from randomly generated data
# no. of samples: 100
# no. of classes: 2
# no. of features: 10
# continuous data: [0, 1)
# allow missing values: true
r1.data_from_random(100, 2, 10, 0, true)

# number of features before feature selection
puts '  # features (before): ' + r1.get_features.size.to_s

# feature selection
r1.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '  # features (after): ' + r1.get_features.size.to_s


# example 2
#


puts "\n  test for discrete feature"

r2 = FSelector::ReliefF_d.new # ReliefF_d is for discrete feature

# read from randomly generated data
# no. of samples: 100
# no. of classes: 2
# no. of features: 15
# no. of possible values for discrete feature: 3
# allow missing values: false
r2.data_from_random(100, 2, 15, 3, true)

# number of features before feature selection
puts '  # features (before): ' + r2.get_features.size.to_s

# feature selection
r2.select_feature_by_rank!('<=5')

# number of features after feature selection
puts '  # features (after): ' + r2.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
