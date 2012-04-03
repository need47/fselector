require 'fselector'

puts "\n======= begin test #{File.basename(__FILE__)} ======="

# use both Information and ChiSquaredTest
r1 = FSelector::InformationGain.new
r2 = FSelector::ChiSquaredTest.new

# ensemble ranker
re = FSelector::Ensemble.new(r1, r2)

# read random data
re.data_from_random(100, 2, 10, 3, true)

# number of features before feature selection
puts '# features (before): ' + re.get_features.size.to_s

# based on the min feature rank among
# ensemble feature selection algorithms
re.ensemble_by_rank(re.method(:by_min))

# select the top-ranked 3 features
re.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '# features before (after): ' + re.get_features.size.to_s

puts "======= end test #{File.basename(__FILE__)} ======="
