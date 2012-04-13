#
# test discretization algorithms
# for continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

puts "  test equal_width discretization"
r1 = FSelector::Relief_c.new # Relief_c is for continuous feature
r1.data_from_csv('test/iris.csv')
r1.discretize_by_equal_width!(2)

puts "  test equal_frequency discretization"
r2 = FSelector::Relief_c.new # Relief_c is for continuous feature
r2.data_from_csv('test/iris.csv')
r2.discretize_by_equal_frequency!(2)

puts "  test ChiMerge discretization"
r3 = FSelector::Relief_c.new # Relief_c is for continuous feature
r3.data_from_csv('test/iris.csv')
r3.discretize_by_ChiMerge!(0.10)

# note our implementation of Chi2 algo is  
# NOT the exactly same as the original one
puts "  test Chi2 discretization"
r3 = FSelector::Relief_c.new # Relief_c is for continuous feature
r3.data_from_csv('test/iris.csv')
r3.discretize_by_Chi2!(0.05)

puts "  test Multi-Interval Discretization (MID)"
r3 = FSelector::Relief_c.new # Relief_c is for continuous feature
r3.data_from_csv('test/iris.csv')
r3.discretize_by_MID!


puts "<============< #{File.basename(__FILE__)}"
