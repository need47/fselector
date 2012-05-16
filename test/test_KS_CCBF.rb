#
# test the Kolmogorov-Smirnov Class Correlation-Based Filter (KS-CCBF) algorithm
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


r = FSelector::KS_CCBF.new(0.2)
r.data_from_random(100, 3, 10, 0, false)

# number of features before feature selection
puts '  # features (before): ' + r.get_features.size.to_s

# note that by defaul KS_CCBF uses discretize_by_ChiMerge!() as discretization method. 
# If you prefer alternative one, you can override the KS_CCBF.discretize_for_suc(). 
# See the Discretizer module for a list of available discretization methods
def r.discretize_for_suc
  self.discretize_by_equal_width!(10)
end


# feature selection
r.select_feature!

# number of features after feature selection
puts '  # features (after): ' + r.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
