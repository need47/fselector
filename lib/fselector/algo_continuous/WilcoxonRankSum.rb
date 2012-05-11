#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Wilcoxon Rank Sum (WRS) for continuous feature
#
# @note WRS is applicable only to two-class problems, and missing data are ignored
#
# for WRS (p-value), the smaller, the better, but we intentionally negate it 
# so that the larger is always the better (consistent with other algorithms).  
# R equivalent: wilcox.test
#
# ref: [An Efficient and Robust Statistical Modeling Approach to Discover Differentially Expressed Genes Using Genomic Expression Profiles](http://genome.cshlp.org/content/11/7/1227)
#
  class WilcoxonRankSum < BaseContinuous
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      if not get_classes.size == 2
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  suitable only for two-class problem with continuous feature"
      end
      
      # collect data for class 1 and 2, respectively     
      k1, k2 = get_classes
      R.s1 = get_feature_values(f, nil, k1) # class 1
      R.s2 = get_feature_values(f, nil, k2) # class 2
      
      # Wilcoxon rank sum test
      R.eval "rv <- wilcox.test(s1, s2)$p.value"
      
      # intensionally negate it
      s = -1.0 * R.rv # pull the p-value from R
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::WRS instead of FSelector::WilcoxonRankSum
  WRS = WilcoxonRankSum
  
  
end # module
