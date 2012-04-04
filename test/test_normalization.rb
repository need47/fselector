#
# test normalization algorithms
# for continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

r1 = FSelector::Relief_c.new # Relief_c is for continuous feature
r1.data_from_csv('test/iris.csv')

puts "  test log2 normalization"
r1.normalize_by_log!(2)

puts "  test min_max normalization"
r1.normalize_by_min_max!(0,1)

puts "  test zscore normalization"
r1.normalize_by_zscore!

puts "<============< #{File.basename(__FILE__)}"
