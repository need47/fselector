#
# test an ensemble of multiple algorithms (i.e., 
# InformationGain (IG) and Relief_d 
# for selecting discrete feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# test for the weighting type of algorithms
# use both InformationGain and Relief_d
r1 = FSelector::InformationGain.new
r2 = FSelector::Relief_d.new

# ensemble ranker
re = FSelector::Ensemble.new(r1, r2)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# based on the max feature score (z-score standardized) among
# an ensemble feature selection algorithms
re.ensemble_by_score(:by_max, :by_zscore)

# select the top-ranked 3 features
re.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s

# test for the subset selection type of algorithms
# use both CFS_d and INTERACT
r1 = FSelector::CFS_d.new
r2 = FSelector::INTERACT.new

# ensemble ranker
re = FSelector::Ensemble.new(r1, r2)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# select feature based on the consensus feautre subset selected by CFS_d and INTERACT
re.select_feature!

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
