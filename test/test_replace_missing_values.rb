#
# test replace missing values algorithms
# for continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


puts "  test replace with fixed value 0.5"
r1 = FSelector::Relief_c.new # Relief_c is for continuous feature
r1.data_from_random(100, 2, 10, 0, true)
r1.replace_by_fixed_value!(0.5)


# example 2
#


puts "  test replace with mean value"
r2 = FSelector::Relief_c.new # Relief_c is for continuous feature
r2.data_from_random(100, 2, 10, 0, true)
r2.replace_by_mean_value!(:by_column)


# example 3
#


puts "  test replace with most seen value"
r3 = FSelector::Relief_d.new # Relief_d is for discrete feature
r3.data_from_random(100, 2, 10, 3, true)
r3.replace_by_most_seen_value!


# example 4
#


puts "  test replace with median value"
r4 = FSelector::Relief_c.new # Relief_c is for continuous feature
r4.data_from_random(100, 2, 10, 0, true)
r4.replace_by_median_value!(:by_row)


# example 5
#


puts "  test replace with knn value"
r5 = FSelector::Relief_c.new # Relief_c is for continuous feature
r5.data_from_random(100, 2, 10, 0, true)
r5.replace_by_knn_value!(3)


puts "<============< #{File.basename(__FILE__)}"
