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
r3.discretize_by_ChiMerge!(4.60)


puts "<============< #{File.basename(__FILE__)}"
