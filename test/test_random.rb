#
# test the Random and RandomSubset algorithm
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#

# Random
puts "  test Random ..."
r1 = FSelector::Rand.new
r1.data_from_random(100, 2, 10, 3, true)
r1.select_feature_by_rank!('<=3')


# example 26
#


# RandomSubset (RandS)
puts "  test RandomSubset ..."
r2 = FSelector::RandS.new(3)
r2.data_from_random(100, 3, 10, 3, true)
r2.select_feature!

puts "<============< #{File.basename(__FILE__)}"
