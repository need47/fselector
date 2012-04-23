FSelector: a Ruby gem for feature selection and ranking
===========================================================

**Home** [https://rubygems.org/gems/fselector](https://rubygems.org/gems/fselector)  
**Source Code**: [https://github.com/need47/fselector](https://github.com/need47/fselector)  
**Documentation** [http://rubydoc.info/gems/fselector/frames](http://rubydoc.info/gems/fselector/frames)  
**Author**: Tiejun Cheng  
**Email**: [need47@gmail.com](mailto:need47@gmail.com)  
**Copyright**: 2012  
**License**: MIT License  
**Latest Version**: 0.8.1  
**Release Date**: April 23 2012

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
random forest. See below for a list of FSelector's features and 
{file:ChangeLog} for updates.

Feature List
------------

**1. supported input/output file types**

 - csv
 - libsvm
 - weka ARFF
 - random data (for test purpose)

**2. available feature selection/ranking algorithms**
    
    algorithm                         alias       feature_type  applicability
    --------------------------------------------------------------------------------------
    Accuracy                          Acc         discrete
    AccuracyBalanced                  Acc2        discrete
    BiNormalSeparation                BNS         discrete
    CFS_d                             CFS_d       discrete
    ChiSquaredTest                    CHI         discrete
    CorrelationCoefficient            CC          discrete
    DocumentFrequency                 DF          discrete
    F1Measure                         F1          discrete
    FishersExactTest                  FET         discrete
    FastCorrelationBasedFilter        FCBF        discrete
    GiniIndex                         GI          discrete
    GMean                             GM          discrete
    GSSCoefficient                    GSS         discrete
    InformationGain                   IG          discrete
    MatthewsCorrelationCoefficient    MCC, PHI    discrete
    McNemarsTest                      MNT         discrete
    OddsRatio                         OR          discrete
    OddsRatioNumerator                ORN         discrete
    PhiCoefficient                    Phi         discrete
    Power                             Power       discrete
    Precision                         Precision   discrete
    ProbabilityRatio                  PR          discrete
    Random                            Random      discrete
    Recall                            Recall      discrete
    Relief_d                          Relief_d    discrete      two-class, no missing data
    ReliefF_d                         ReliefF_d   discrete
    Sensitivity                       SN, Recall  discrete
    Specificity                       SP          discrete
    SymmetricalUncertainty            SU          discrete
    BetweenWithinClassesSumOfSquare   BSS_WSS     continuous
    CFS_c                             CFS_c       continuous
    FTest                             FT          continuous
    PMetric                           PM          continuous    two-class
    Relief_c                          Relief_c    continuous    two-class, no missing data
    ReliefF_c                         ReliefF_c   continuous
    TScore                            TS          continuous    two-class
    WilcoxonRankSum                   WRS         continuous    two-class
    
  **note for feature selection interace:**   
    - for the algorithms of CFS\_d, FCBF and CFS\_c, use select\_feature!  
    - for other algorithms, use either select\_feature\_by\_rank! or select\_feature\_by\_score!

**3. feature selection approaches**

 - by a single algorithm
 - by multiple algorithms in a tandem manner
 - by multiple algorithms in a consensus manner
 
**4. availabe normalization and discretization algorithms for continuous feature**
    
    algorithm                         note
    -------------------------------------------------------------------------------
    normalize_by_log!                 normalize by logarithmic transformation
    normalize_by_min_max!             normalize by scaling into [min, max]
    normalize_by_zscore!              normalize by converting into zscore
    discretize_by_equal_width!        discretize by equal width among intervals
    discretize_by_equal_frequency!    discretize by equal frequency among intervals
    discretize_by_ChiMerge!           discretize by ChiMerge algorithm
    discretize_by_Chi2!               discretize by Chi2 algorithm
    discretize_by_MID!                discretize by Multi-Interval Discretization
    
**5. availabe algorithms for replacing missing feature values**
    
    algorithm                         note                                feature_type                     
    -------------------------------------------------------------------------------------------
    replace_by_fixed_value!           replace by a fixed value            discrete, continuous
    replace_by_mean_value!            replace by mean feature value       continuous
    replace_by_most_seen_value!       replace by most seen feature value  discrete

Installing
----------

To install FSelector, use the following command:

    $ gem install fselector
    
  **note:** Start from version 0.5.0, FSelector uses the RinRuby gem (http://rinruby.ddahl.org) 
  as a seemless bridge to access the statistical routines in the R package (http://www.r-project.org), 
  which will greatly expand the inclusion of algorithms to FSelector, especially for those relying 
  on statistical test. To this end, please pre-install the R package. RinRuby should have been 
  auto-installed with FSelector via the above command.
  
Usage
-----

**1. feature selection by a single algorithm**

    require 'fselector'
	
    # use InformationGain as a feature ranking algorithm
    r1 = FSelector::InformationGain.new
    
    # read from random data (or csv, libsvm, weka ARFF file)
    # no. of samples: 100
    # no. of classes: 2
    # no. of features: 15
    # no. of possible values for each feature: 3
    # allow missing values: true
    r1.data_from_random(100, 2, 15, 3, true)
    
    # number of features before feature selection
    puts "# features (before): "+ r1.get_features.size.to_s
    
    # select the top-ranked features with scores >0.01
    r1.select_feature_by_score!('>0.01')
    
    # number of features after feature selection
    puts "# features (after): "+ r1.get_features.size.to_s
    
    # you can also use multiple alogirithms in a tandem manner
    # e.g. use the ChiSquaredTest with Yates' continuity correction
    # initialize from r1's data
    r2 = FSelector::ChiSquaredTest.new(:yates_continuity_correction, r1.get_data)
    
    # number of features before feature selection
    puts "# features (before): "+ r2.get_features.size.to_s
    
    # select the top-ranked 3 features
    r2.select_feature_by_rank!('<=3')
    
    # number of features after feature selection
    puts "# features (after): "+ r2.get_features.size.to_s
    
    # save data to standard ouput as a weka ARFF file (sparse format)
    # with selected features only
    r2.data_to_weka(:stdout, :sparse)

	
**2. feature selection by an ensemble of multiple algorithms**

    require 'fselector'
	
	# use both Information and ChiSquaredTest
    r1 = FSelector::InformationGain.new
    r2 = FSelector::ChiSquaredTest.new
    
    # ensemble ranker
    re = FSelector::Ensemble.new(r1, r2)
    
    # read random data
    re.data_from_random(100, 2, 15, 3, true)
    
    # number of features before feature selection
    puts '# features (before): ' + re.get_features.size.to_s
    
    # based on the min feature rank among
    # ensemble feature selection algorithms
    re.ensemble_by_rank(re.method(:by_min))
    
    # select the top-ranked 3 features
    re.select_feature_by_rank!('<=3')
    
    # number of features after feature selection
    puts '# features (after): ' + re.get_features.size.to_s

    
**3. normalization and discretization before feature selection**

 In addition to the algorithms designed for continuous feature, one
 can apply those deisgned for discrete feature after (optionally
 normalization and) discretization
 
    require 'fselector'
    
    # for continuous feature
    r1 = FSelector::Relief_c.new
    
    # read the Iris data set (under the test/ directory)
    r1.data_from_csv('test/iris.csv')
        
    # discretization by ChiMerge algorithm at alpha=0.10
    r1.discretize_by_ChiMerge!(0.10)
    
    # apply Fast Correlation-Based Filter (FCBF) algorithm for discrete feature
    # initialize with discretized data from r1
    r2 = FSelector::FCBF.new(0.0, r1.get_data)
    
    # number of features before feature selection
    puts '# features (before): ' + r2.get_features.size.to_s
    
    # feature selection
    r2.select_feature!
    
    # number of features after feature selection
    puts '# features (after): ' + r2.get_features.size.to_s

**4. see more examples test_*.rb under the test/ directory**

Change Log
----------
A {file:ChangeLog} is available from version 0.5.0 and upward to refelect 
what's new and what's changed 

Copyright
---------
FSelector &copy; 2012 by [Tiejun Cheng](mailto:need47@gmail.com).
FSelector is licensed under the MIT license. Please see the {file:LICENSE} for
more information.
