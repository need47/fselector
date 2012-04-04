#
# test an ensemble of multiple algorithms (i.e., 
# InformationGain (IG) and Relief_d 
# for selecting discrete feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# use both InformationGain and Relief_d
r1 = FSelector::InformationGain.new
r2 = FSelector::Relief_d.new

# ensemble ranker
re = FSelector::Ensemble.new(r1, r2)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# based on the min feature rank among
# ensemble feature selection algorithms
re.ensemble_by_rank(re.method(:by_min))

# select the top-ranked 3 features
re.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
