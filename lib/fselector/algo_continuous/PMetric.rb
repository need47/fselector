#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# P-Metric (PM) for continous feature
#
#                 |u1 - u2|
#     PM(f) = -----------------
#              sigma1 + sigma2
#
# @note PM applicable only to two-class problems
#
# ref: [Filter versus wrapper gene selection approaches](http://www.sciencedirect.com/science/article/pii/S0933365704000193)
#
  class PMetric < BaseContinuous
    
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      if not get_classes.size == 2
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "suitable only for two-class problem with continuous feature"
      end
      
      # collect data for class 1 and 2, respectively
      s1, s2 = [], []      
      k1, k2 = get_classes
      
      each_sample do |k, ss|
        s1 << ss[f] if k == k1 and ss.has_key? f 
        s2 << ss[f] if k == k2 and ss.has_key? f
      end
      
      # calc
      s = (s1.ave-s2.ave).abs / (s1.sd+s2.sd)
      
      set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
        
  end # class 
  
  
  # shortcut so that you can use FSelector::PM instead of FSelector::PMetric
  PM = PMetric
  
  
end # module
