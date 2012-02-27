FSelector: a Ruby package for feature selection and ranking
===========================================================

**Git**: [https://github.com/need47/fselector](https://github.com/need47/fselector)  
**Author**: Tiejun Cheng  
**Email**: [need47@gmail.com](mailto:need47@gmail.com)  
**Copyright**: 2011-2012  
**License**: MIT License  
**Latest Version**: 0.1.0  
**Release Date**: March 1st 2012

Synopsis
--------

FSelector is an open-access Ruby package that aims to integrate as many 
feature selection/ranking algorithms as possible. It enables the 
user to perform feature selection by either a single algorithm or by an 
ensemble of algorithms. Below is a summary of FSelector's features.

Feature List
------------

**1. available algorithms**
    
    algorithm                       alias      feature type
    -------------------------------------------------------
    Accuracy                        Acc         discrete
    AccuracyBalanced                Acc2        discrete
    BiNormalSeparation              BNS         discrete
    ChiSquaredTest                  CHI         discrete
    CorrelationCoefficient          CC          discrete
    DocumentFrequency               DF          discrete
    F1Measure                       F1          discrete
    FishersExactTest                FET         discrete
    GiniIndex                       GI          discrete
    GMean                           GM          discrete
    GSSCoefficient                  GSS         discrete
    InformationGain                 IG          discrete
    MatthewsCorrelationCoefficient  MCC, PHI    discrete
    McNemarsTest                    MNT         discrete
    OddsRatio                       OR          discrete
    OddsRatioNumerator              ORN         discrete
    PhiCoefficient                  Phi         discrete
    Power                           Power       discrete
    Precision                       Precision   discrete
    ProbabilityRatio                PR          discrete
    Random                          Random      discrete
    Recall                          Recall      discrete
    Relief_d                        Relief_d    discrete
    ReliefF_d                       ReliefF_d   discrete
    Sensitivity                     SN, Recall  discrete
    Specificity                     SP          discrete
    PMetric                         PM          continuous
    Relief_c                        Relief_c    continuous
    ReliefF_c                       ReliefF_c   continuous
    TScore                          TS          continuous

**2. feature selection approaches**

 - by a single algorithm
 - by multiple algorithms in a tandem manner
 - by multiple algorithms in a consensus manner
 
**3. availabe normalization and discretization algorithms for continuous feature**
    
    algorithm          note
    --------------------------------------------------------------------
    log                normalization by logarithmic transformation
    min_max            normalization by scaling into [min, max]
    zscore             normalization by converting into zscore
    equal_width        discretization by equal width among intervals
    equal_frequency    discretization by equal frequency among intervals
    ChiMerge           discretization by ChiMerge method
    
**4. supported input/output file types**

 - csv
 - libsvm
 - weka ARFF
 - random (for test purpose)

Installing
----------

To install FSelector, use the following command:

    $ gem install fselector
	
Usage
-----

**1. feature selection by a single algorithm**

    require 'fselector'
	
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
    
    # you can also use multiple alogirithms in a tandem manner
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

	
**2. feature selection by an ensemble of algorithms**

    require 'fselector'
	
	# use both Information and ChiSquaredTest
    r1 = FSelector::InformationGain.new
    r2 = FSelector::ChiSquaredTest.new
    
    # ensemble ranker
    re = FSelector::Ensemble.new(r1, r2)
    
    # read random data
    re.data_from_random(100, 2, 10, 3, true)
    
    # number of features before feature selection
    puts '# features before feature selection: ' + re.get_features.size.to_s
    
    # based on the min feature rank among
    # ensemble feature selection algorithms
    re.ensemble_by_rank(re.method(:by_min))
    
    # select the top-ranked 3 features
    re.select_data_by_rank!('<=3')
    
    # number of features before feature selection
    puts '# features before feature selection: ' + re.get_features.size.to_s

    
 **3. normalization and discretization before feature selection**

 In addition to the algorithms designed for continous feature, one
 can apply those deisgned for discrete feature after (optionally
 normalization and) discretization
 
    require 'fselector'
    
    # for continuous feature
    r1 = FSelector::BaseContinuous.new
    
    # read the Iris data set (under the test/ directory)
    r1.data_from_csv(File.expand_path(File.dirname(__FILE__))+'/iris.csv')
    
    # normalization by log2 (optional)
    # r1.normalize_log!(2)
    
    # discretization by ChiMerge algorithm
    # chi-squared value = 4.60 for a three-class problem at alpha=0.10
    r1.discretize_chimerge!(4.60)
    
    # apply Relief_d for discrete feature
    # initialize with discretized data from r1
    r2 = FSelector::ReliefF_d.new(r1.get_sample_size, 10, r1.get_data)
    
    # print feature ranks
    r2.print_feature_ranks

Copyright
---------
FSelector &copy; 2011-2012 by [Tiejun Cheng](mailto:need47@gmail.com).
FSelector is licensed under the MIT license. Please see the {file:LICENSE} for
more information.
