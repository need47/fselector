#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Information Gain for feature with discrete data (IG)
#
#     IG(c,f) = H(c) - H(c|f)
#     
#     where H(c) = -1 * sigma_i (P(ci) logP(ci))
#           H(c|f) = sigma_j (P(fj)*H(c|fj))
#           H(c|fj) = -1 * sigma_k (P(ck|fj) logP(ck|fj))
#
# ref: [Using Information Gain to Analyze and Fine Tune the Performance of Supply Chain Trading Agents](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.141.7895)
#
  class InformationGain < BaseDiscrete

    private
  
    # calculate contribution of each feature (f) across all classes
    # see entropy-related functions in BaseDiscrete
    def calc_contribution(f)
      hc, hcf = get_Hc, get_Hcf(f)
      
      s =  hc - hcf
      
      set_feature_score(f, :BEST, s)      
    end # calc_contribution 
        
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::IG instead of FSelector::InformationGain
  IG = InformationGain
  
  
end # module
