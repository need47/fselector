#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# t-score (TS) based on Student's t-test for continous feature
# 
#                            |u1 - u2|
#     TS(f) = --------------------------------------------
#              sqrt((n1*sigma1^2 + n_2*sigma2^2)/(n1+n2))
#
# @note TS applicable only to two-class problems
#
# ref: [Filter versus wrapper gene selection approaches][url]
# [url]: http://www.sciencedirect.com/science/article/pii/S0933365704000193
#
  class TScore < BaseContinuous
        
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
      n1, n2 = s1.size, s2.size
      s = (s1.ave-s2.ave).abs / Math.sqrt( (n1*s1.var+n2*s2.var) / (n1+n2) )
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::TS instead of FSelector::TScore
  TS = TScore
  
  
end # module
