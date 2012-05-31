FSelector: a Ruby gem for feature selection and ranking
===========================================================

**Home**: [https://rubygems.org/gems/fselector](https://rubygems.org/gems/fselector)  
**Source Code**: [https://github.com/need47/fselector](https://github.com/need47/fselector)  
**Documentation** [http://rubydoc.info/gems/fselector/frames](http://rubydoc.info/gems/fselector/frames)  
**Author**: Tiejun Cheng  
**Email**: [need47@gmail.com](mailto:need47@gmail.com)  
**Copyright**: 2012  
**License**: MIT License  
**Latest Version**: 1.3.1  
**Release Date**: 2012-05-31

Synopsis
--------

FSelector is a Ruby gem that aims to integrate various feature 
selection/ranking algorithms and related functions into one single 
package. Welcome to contact me (need47@gmail.com) if you'd like to 
contribute your own algorithms or report a bug. FSelector allows user 
to perform feature selection by using either a single algorithm or an 
ensemble of multiple algorithms, and other common tasks including 
normalization and discretization on continuous data, as well as replace 
missing feature values with certain criterion. FSelector acts on a 
full-feature data set in either CSV, LibSVM or WEKA file format and 
outputs a reduced data set with only selected subset of features, which 
can later be used as the input for various machine learning softwares 
such as LibSVM and WEKA. FSelector, as a collection of filter methods, 
does not implement any classifier like support vector machines or 
random forest. Check below for a list of FSelector's features, 
{file:ChangeLog} for updates, and {file:HowToContribute} if you want 
to contribute.

Feature List
------------

**1. supported input/output file types**

 - csv
 - libsvm
 - weka ARFF
 - on-line dataset in one of the above three formats (read only)
 - random data (read only, for test purpose)

**2. available feature selection/ranking algorithms**
    
    algorithm                        shortcut    algo_type  applicability  feature_type
    --------------------------------------------------------------------------------------------------
    Accuracy                         Acc         weighting  multi-class    discrete
    AccuracyBalanced                 Acc2        weighting  multi-class    discrete
    BiNormalSeparation               BNS         weighting  multi-class    discrete
    CFS_d                            CFS_d       subset     multi-class    discrete
    ChiSquaredTest                   CHI         weighting  multi-class    discrete
    CorrelationCoefficient           CC          weighting  multi-class    discrete
    DocumentFrequency                DF          weighting  multi-class    discrete
    F1Measure                        F1          weighting  multi-class    discrete
    FishersExactTest                 FET         weighting  multi-class    discrete
    FastCorrelationBasedFilter       FCBF        subset     multi-class    discrete
    GiniIndex                        GI          weighting  multi-class    discrete
    GMean                            GM          weighting  multi-class    discrete
    GSSCoefficient                   GSS         weighting  multi-class    discrete
    InformationGain                  IG          weighting  multi-class    discrete
    INTERACT                         INTERACT    subset     multi-class    discrete
    JMeasure                         JM          weighting  multi-class    discrete
    KLDivergence                     KLD         weighting  multi-class    discrete
    MatthewsCorrelationCoefficient   MCC, PHI    weighting  multi-class    discrete
    McNemarsTest                     MNT         weighting  multi-class    discrete
    OddsRatio                        OR          weighting  multi-class    discrete
    OddsRatioNumerator               ORN         weighting  multi-class    discrete
    PhiCoefficient                   PHI         weighting  multi-class    discrete
    Power                            Power       weighting  multi-class    discrete
    Precision                        Precision   weighting  multi-class    discrete
    ProbabilityRatio                 PR          weighting  multi-class    discrete
    Recall                           Recall      weighting  multi-class    discrete
    Relief_d                         Relief_d    weighting  two-class      discrete
    ReliefF_d                        ReliefF_d   weighting  multi-class    discrete
    Sensitivity                      SN, Recall  weighting  multi-class    discrete
    Specificity                      SP          weighting  multi-class    discrete
    SymmetricalUncertainty           SU          weighting  multi-class    discrete
    BetweenWithinClassesSumOfSquare  BSS_WSS     weighting  multi-class    continuous
    CFS_c                            CFS_c       subset     multi-class    continuous
    FTest                            FT          weighting  multi-class    continuous
    KS_CCBF                          KS_CCBF     subset     multi-class    continuous
    KSTest                           KST         weighting  two-class      continuous
    PMetric                          PM          weighting  two-class      continuous
    Relief_c                         Relief_c    weighting  two-class      continuous
    ReliefF_c                        ReliefF_c   weighting  multi-class    continuous
    TScore                           TS          weighting  two-class      continuous
    WilcoxonRankSum                  WRS         weighting  two-class      continuous
    LasVegasFilter                   LVF         subset     multi-class    discrete, continuous, mixed
    LasVegasIncremental              LVI         subset     multi-class    discrete, continuous, mixed
    Random                           Rand        weighting  multi-class    discrete, continuous, mixed
    RandomSubset                     RandS       subset     multi-class    discrete, continuous, mixed
    
  **note for feature selection interface:**   
  there are two types of filter methods, i.e., feature weighting algorithms and feature subset selection algorithms  
  
  - for weighting type: use either **select\_feature\_by\_score!** or **select\_feature\_by\_rank!**  
  - for subset type: use **select\_feature!**

**3. feature selection approaches**

 - by a single algorithm
 - by multiple algorithms in a tandem manner
 - by multiple algorithms in an ensemble manner (share the same feature selection interface as single algorithm)
 
**4. availabe normalization and discretization algorithms for continuous feature**
    
    algorithm                         note
    ---------------------------------------------------------------------------------------
    normalize_by_log!                 normalize by logarithmic transformation
    normalize_by_min_max!             normalize by scaling into [min, max]
    normalize_by_zscore!              normalize by converting into zscore
    discretize_by_equal_width!        discretize by equal width among intervals
    discretize_by_equal_frequency!    discretize by equal frequency among intervals
    discretize_by_ChiMerge!           discretize by ChiMerge algorithm
    discretize_by_Chi2!               discretize by Chi2 algorithm
    discretize_by_MID!                discretize by Multi-Interval Discretization algorithm
    discretize_by_TID!                discretize by Three-Interval Discretization algorithm
    
**5. availabe algorithms for replacing missing feature values**
    
    algorithm                         note                                   feature_type                     
    ---------------------------------------------------------------------------------------------
    replace_by_fixed_value!           replace by a fixed value               discrete, continuous
    replace_by_mean_value!            replace by mean feature value          continuous
    replace_by_median_value!          replace by median feature value        continuous
    replace_by_knn_value!             replace by weighted knn feature value  continuous
    replace_by_most_seen_value!       replace by most seen feature value     discrete

Installing
----------

To install FSelector, use the following command:

    $ gem install fselector
    
  **note:** From version 0.5.0, FSelector uses the RinRuby gem (http://rinruby.ddahl.org) 
  as a seemless bridge to access the statistical routines in the R package (http://www.r-project.org), 
  which will greatly expand the inclusion of algorithms to FSelector, especially for those relying 
  on statistical test. To this end, please pre-install the R package. RinRuby should have been 
  auto-installed with FSelector via the above command.
  
Usage
-----

**1. feature selection by a single algorithm**
    
    require 'fselector'
	
    # use InformationGain (IG) as a feature selection algorithm
    r1 = FSelector::IG.new
    
    # read from random data (or csv, libsvm, weka ARFF file)
    # no. of samples: 100
    # no. of classes: 2
    # no. of features: 15
    # no. of possible values for each feature: 3
    # allow missing values: true
    r1.data_from_random(100, 2, 15, 3, true)
    
    # number of features before feature selection
    puts "  # features (before): "+ r1.get_features.size.to_s
    
    # select the top-ranked features with scores >0.01
    r1.select_feature_by_score!('>0.01')
    
    # number of features after feature selection
    puts "  # features (after): "+ r1.get_features.size.to_s
    
    # you can also use a second alogirithm for further feature selection
    # e.g. use the ChiSquaredTest (CHI) with Yates' continuity correction
    # initialize from r1's data
    r2 = FSelector::CHI.new(:yates, r1.get_data)
    
    # number of features before feature selection
    puts "  # features (before): "+ r2.get_features.size.to_s
    
    # select the top-ranked 3 features
    r2.select_feature_by_rank!('<=3')
    
    # number of features after feature selection
    puts "  # features (after): "+ r2.get_features.size.to_s
    
    # save data to standard ouput as a weka ARFF file (sparse format)
    # with selected features only
    r2.data_to_weka(:stdout, :sparse)

	
**2. feature selection by an ensemble of multiple feature selectors**
    
    require 'fselector'
	
	# example 1
	#
	
	
	# creating an ensemble of feature selectors by using 
	# a single feature selection algorithm (INTERACT) 
	# by instance perturbation (e.g. random sampling)
	
	# test for the type of feature subset selection algorithms
    r = FSelector::INTERACT.new(0.0001)

    # an ensemble of 40 feature selectors with 90% data by random sampling
    re = FSelector::EnsembleSingle.new(r, 40, 0.90, :random_sampling)

    # read SPECT data set  (under the test/ directory)
    re.data_from_csv('test/SPECT_train.csv')

    # number of features before feature selection
    puts '  # features (before): ' + re.get_features.size.to_s

    # only features with above average count among ensemble are selected
    re.select_feature!

    # number of features after feature selection
    puts '  # features before (after): ' + re.get_features.size.to_s

    
    # example 2
	#
	
	
	# creating an ensemble of feature selectors by using 
	# two feature selection algorithms: InformationGain (IG) and Relief_d. 
	# note: can be 2+ algorithms, as long as they are of the same type, 
	# either feature weighting or feature subset selection algorithms
	
	# test for the type of feature weighting algorithms 
    r1 = FSelector::IG.new
    r2 = FSelector::Relief_d.new(10)
    
    # an ensemble of two feature selectors
    re = FSelector::EnsembleMultiple.new(r1, r2)
    
    # read random discrete data (containing missing value)
    re.data_from_random(100, 2, 15, 3, true)
    
    # replace missing value because Relief_d 
    # does not allow missing value
    re.replace_by_most_seen_value!
    
    # number of features before feature selection
    puts '  # features (before): ' + re.get_features.size.to_s
    
    # based on the max feature score (z-score standardized) among
    # an ensemble of feature selectors
    re.ensemble_by_score(:by_max, :by_zscore)
    
    # select the top-ranked 3 features
    re.select_feature_by_rank!('<=3')
    
    # number of features after feature selection
    puts '  # features (after): ' + re.get_features.size.to_s
    
**3. feature selection after discretization**
    
    require 'fselector'
    
    # the Information Gain (IG) algorithm requires data with discrete feature
    r = FSelector::IG.new
    
    # but the Iris data set contains continuous features
    r.data_from_url('http://repository.seasr.org/Datasets/UCI/arff/iris.arff', :weka)
        
    # let's first discretize it by ChiMerge algorithm at alpha=0.10
    # then perform feature selection as usual
    r.discretize_by_ChiMerge!(0.10)
    
    # number of features before feature selection
    puts '  # features (before): ' + r.get_features.size.to_s
    
    # select the top-ranked feature
    r.select_feature_by_rank!('<=1')
    
    # number of features after feature selection
    puts '  # features (after): ' + r.get_features.size.to_s

**4. see more examples test_*.rb under the test/ directory**

How to contribute
-----------------
check {file:HowToContribute} to see how to write your own feature selection algorithms and/or make contribution to FSelector.

Change Log
----------

A {file:ChangeLog} is available from version 0.5.0 and upward to refelect 
what's new and what's changed.

Copyright
---------

FSelector &copy; 2012 by [Tiejun Cheng](mailto:need47@gmail.com).
FSelector is licensed under the MIT license. Please see the {file:LICENSE} for
more information.
