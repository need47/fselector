#
# test multiple algorithms in a tandem manner
# for selecting feature (e.g. discrete feature)
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# use InformationGain as a feature ranking algorithm
r1 = FSelector::InformationGain.new

# read from SPECT data set (in CSV format)
r1.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts "  # features (before): "+ r1.get_features.size.to_s

# select the top-ranked features with scores >0.05
r1.select_feature_by_score!('>0.05')

# number of features after feature selection
puts "  # features (after): "+ r1.get_features.size.to_s

# use a second alogirithm in a tandem manner
# e.g. Fishers' Exact Test (FET), initialize from r1's data
r2 = FSelector::FET.new(r1.get_data)

# number of features before feature selection
puts "  # features (before): "+ r2.get_features.size.to_s

# select the top-ranked 3 features
r2.select_feature_by_rank!('<=3')

# number of features after feature selection
puts "  # features (after): "+ r2.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
