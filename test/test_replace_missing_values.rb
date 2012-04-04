#
# test replace missing values algorithms
# for continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

puts "  test replace with fixed value 0.5"
r1 = FSelector::Relief_c.new # Relief_c is for continuous feature
r1.data_from_random(100, 2, 10, 0, true)
r1.replace_with_fixed_value!(0.5)

puts "  test replace with mean value"
r2 = FSelector::Relief_c.new # Relief_c is for continuous feature
r2.data_from_random(100, 2, 10, 0, true)
r2.replace_with_mean_value!

puts "  test replace with most seen value"
r3 = FSelector::Relief_d.new # Relief_d is for discrete feature
r3.data_from_random(100, 2, 10, 3, true)
r3.replace_with_most_seen_value!

puts "<============< #{File.basename(__FILE__)}"
