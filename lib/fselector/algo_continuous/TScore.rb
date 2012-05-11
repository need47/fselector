#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# t-score (TS) based on Student's t-test for continuous feature
# 
#                      |u1 - u2|
#     TS = -------------------------------------
#           sqrt((n1*sd1^2 + n2*sd2^2)/(n1+n2))
#
# @note TS applicable only to two-class problems
#
# ref: [Filter versus wrapper gene selection approaches](http://www.sciencedirect.com/science/article/pii/S0933365704000193)
#
  class TScore < BaseContinuous
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
      s1 = get_feature_values(f, nil, k1)
      s2 = get_feature_values(f, nil, k2)
      
      # calc
      n1, n2 = s1.size, s2.size
      x = n1+n2
      
      if not x.zero?
        dd = Math.sqrt( (n1*s1.var+n2*s2.var) / x )
      end
      
      s = 0.0
      if not dd.zero?
        s = (s1.ave-s2.ave).abs / dd
      end
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::TS instead of FSelector::TScore
  TS = TScore
  
  
end # module
