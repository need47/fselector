#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# KS-Test (KST) based on Kolmogorov-Smirnov statistical test for continuous feature
# 
# @note KST is applicable only to two-class problems, and missing data are ignored
#
# for KST (p-value), the smaller, the better, but we intentionally negate it 
# so that the larger is always the better (consistent with other algorithms).  
# R equivalent: ks.test
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test) and [Feature Extraction, Foundations and Applications](http://www.springer.com/engineering/computational+intelligence+and+complexity/book/978-3-540-35487-1)
#
  class KSTest < BaseContinuous
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
      
      # K-S test
      R.eval "rv <- ks.test(s1, s2)$p.value"
      
      # intensionally negate it
      s = -1.0 * R.rv # pull the p-value from R
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::KST instead of FSelector::KSTest
  KST = KSTest
  
  
end # module
