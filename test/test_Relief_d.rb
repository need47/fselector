require 'fselector'

puts "\n======= begin test #{File.basename(__FILE__)} ======="

# for continuous feature
r1 = FSelector::BaseContinuous.new

# read the Iris data set (under the test/ directory)
r1.data_from_csv(File.expand_path(File.dirname(__FILE__))+'/iris.csv')

# normalization by log2 (optional)
# r1.normalize_log!(2)

# discretization by ChiMerge algorithm
# chi-squared value = 4.60 for a three-class problem at alpha=0.10
r1.discretize_by_ChiMerge!(4.60)

# apply Relief_d for discrete feature
# initialize with discretized data from r1
r2 = FSelector::ReliefF_d.new(r1.get_sample_size, 10, r1.get_data)

# print feature ranks
puts r2.get_feature_ranks

puts "======= end test #{File.basename(__FILE__)} ======="
