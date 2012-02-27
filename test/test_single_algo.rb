require 'fselector'

puts "\n======= begin test #{File.basename(__FILE__)} ======="

# use InformationGain as a feature ranking algorithm
r1 = FSelector::InformationGain.new

# read from random data (or csv, libsvm, weka ARFF file)
# no. of samples: 100
# no. of classes: 2
# no. of features: 10
# no. of possible values for each feature: 3
# allow missing values: true
r1.data_from_random(100, 2, 10, 3, true)

# number of features before feature selection
puts "# features (before): "+ r1.get_features.size.to_s

# select the top-ranked features with scores >0.01
r1.select_data_by_score!('>0.01')

# number of features before feature selection
puts "# features (after): "+ r1.get_features.size.to_s

# you can also use various alogirithms in a tandem manner
# e.g. use the ChiSquaredTest with Yates' continuity correction
# initialize from r1's data
r2 = FSelector::ChiSquaredTest.new(:yates, r1.get_data)

# number of features before feature selection
puts "# features (before): "+ r2.get_features.size.to_s

# select the top-ranked 3 features
r2.select_data_by_rank!('<=3')

# number of features before feature selection
puts "# features (after): "+ r2.get_features.size.to_s

# save data to standard ouput as a weka ARFF file (sparse format)
# with selected features only
r2.data_to_weka(:stdout, :sparse)

puts "======= end test #{File.basename(__FILE__)} ======="
