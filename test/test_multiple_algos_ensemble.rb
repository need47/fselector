#
# test an ensemble of multiple algorithms (i.e., 
# InformationGain (IG) and Relief_d 
# for selecting discrete feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# example 1
#


# test ensemble of multiple feature selectors of the same algorithm

# test for the weighting type of algorithm
# use InformationGain
# no need to use .new
r = FSelector::IG

# an ensemble of 40 selectors with 90% data by bootstrap sampling
re = FSelector::EnsembleSingle.new(r, 40, 0.90, :bootstrap_sampling)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# based on the sum of feature rank among ensemble
re.ensemble_by_rank(:by_sum)

# select the top-ranked 3 features
re.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s


# example 2
#


# test ensemble of multiple feature selectors of the same algorithm

# test for the subset selection type of algorithm
# use INTERACT
# no need to use .new
r = FSelector::INTERACT

# an ensemble of 40 selectors with 90% data by random sampling
re = FSelector::EnsembleSingle.new(r, 40, 0.90, :random_sampling)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# only features with above average count among ensemble are selected
re.select_feature!

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s


# example 3
#


# test ensemble of multiple algorithms

# test for the weighting type of algorithms
# use both InformationGain and Relief_d
# no need to use .new
r1 = FSelector::IG
r2 = FSelector::Relief_d

# an ensemble of two feature selectors (IG and Relief_d)
re = FSelector::EnsembleMultiple.new(r1, r2)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# based on the max feature score (z-score standardized) among ensemble
re.ensemble_by_score(:by_max, :by_zscore)

# select the top-ranked 3 features
re.select_feature_by_rank!('<=3')

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s


# example 4
#


# test ensemble of multiple algorithms

# test for the subset selection type of algorithms
# use both CFS_d and INTERACT
# no need to use .new
r1 = FSelector::CFS_d
r2 = FSelector::INTERACT

# an ensemble of two feature selectors (CFS_d and INTERACT)
re = FSelector::EnsembleMultiple.new(r1, r2)

# read SPECT data set
re.data_from_csv('test/SPECT_train.csv')

# number of features before feature selection
puts '  # features (before): ' + re.get_features.size.to_s

# only features with above average count among ensemble are selected
re.select_feature!

# number of features after feature selection
puts '  # features before (after): ' + re.get_features.size.to_s

puts "<============< #{File.basename(__FILE__)}"
