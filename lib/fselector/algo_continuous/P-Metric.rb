#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# P-Metric (PM) for continuous feature
#
#           |u1 - u2|
#     PM = -----------
#           sd1 + sd2
#
# @note PM applicable only to two-class problems
#
# ref: [Filter versus wrapper gene selection approaches in DNA microarray domains](http://www.sciencedirect.com/science/article/pii/S0933365704000193)
#
  class PMetric < BaseContinuous
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
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
      s = 0.0
      dd = s1.sd+s2.sd
      if not dd.zero?
        s = (s1.ave-s2.ave).abs / dd
      end
      
      set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
        
  end # class 
  
  
  # shortcut so that you can use FSelector::PM instead of FSelector::PMetric
  PM = PMetric
  
  
end # module
