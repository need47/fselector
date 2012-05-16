#
# test discretization algorithms
# for continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


puts "  test equal_width discretization"
r1 = FSelector::IG.new # IG requires discrete feature
r1.data_from_csv('test/iris.csv') # but reads continuous feature
r1.discretize_by_equal_width!(2) # first discretization by equal width
r1.select_feature_by_rank!('<=3') # then feature selection as usual


# example 2
#


puts "  test equal_frequency discretization"
r2 = FSelector::IG.new # IG requires discrete feature
r2.data_from_csv('test/iris.csv') # but reads continuous feature
r2.discretize_by_equal_frequency!(2) # first discretization by equal frequency
r2.select_feature_by_rank!('<=3') # then feature selection as usual


# example 3
#


puts "  test ChiMerge discretization"
r3 = FSelector::IG.new # IG requires discrete feature
r3.data_from_csv('test/iris.csv') # but reads continuous feature
r3.discretize_by_ChiMerge!(0.10) # first discretization by ChiMerge
r3.select_feature_by_rank!('<=3') # then feature selection as usual


# example 4
#


puts "  test Chi2 discretization"
r4 = FSelector::IG.new # IG requires discrete feature
r4.data_from_csv('test/iris.csv') # but reads continuous feature
r4.discretize_by_Chi2!(0.02) # first discretization by Chi2
r4.select_feature_by_rank!('<=3') # then feature selection as usual


# example 5
#


puts "  test Multi-Interval Discretization (MID)"
r5 = FSelector::IG.new # IG requires discrete feature
r5.data_from_csv('test/iris.csv') # but reads continuous feature
r5.discretize_by_MID! # first discretization by MID
r5.select_feature_by_rank!('<=3') # then feature selection as usual


# example 6
#


puts "  test Three-Interval Discretization (TID)"
r6 = FSelector::IG.new # IG requires discrete feature
r6.data_from_csv('test/iris.csv') # read continuous feature
r6.discretize_by_TID! # first discretization by TID
r6.select_feature_by_rank!('<=3') # then feature selection as usual

puts "<============< #{File.basename(__FILE__)}"
