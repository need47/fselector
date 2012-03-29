#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Symmetrical Uncertainty for feature with discrete data (SU)
#
#                      IG(c|f)       H(c) - H(c|f)
#     SU(c,f) = 2 * ------------- = ---------------
#                    H(c) + H(f)      H(c) + H(f)
#     
#     where H(c) = -1 * sigma_i (P(ci) logP(ci))
#           H(c|f) = sigma_j (P(fj)*H(c|fj))
#           H(c|fj) = -1 * sigma_k (P(ck|fj) logP(ck|fj))
#           H(f) = -1 * sigma_i (P(fi) logP(fi))
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Symmetric_uncertainty)
#
  class SymmetricalUncertainty < BaseDiscrete

    private
  
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      hc, hcf, hf = get_Hc, get_Hcf(f), get_Hf(f)
      
      s =  2*(hc-hcf)/(hc+hf)
     
      set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::SU instead of FSelector::SymmetricalUncertainty
  SU = SymmetricalUncertainty
  
  
end # module
