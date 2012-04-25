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
#     where H(c) = -1 * sigma_i (P(ci) log2 P(ci))
#           H(c|f) = sigma_j (P(fj)*H(c|fj))
#           H(c|fj) = -1 * sigma_k (P(ck|fj) log2 P(ck|fj))
#           H(f) = -1 * sigma_i (P(fi) log2 P(fi))
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Symmetric_uncertainty)
#
  class SymmetricalUncertainty < BaseDiscrete
    # include Entropy module
    include Entropy

    private
  
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      cv = get_class_labels
      fv = get_feature_values(f, :include_missing_values)
      
      s = get_symmetrical_uncertainty(cv, fv)
     
      set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::SU instead of FSelector::SymmetricalUncertainty
  SU = SymmetricalUncertainty
  
  
end # module
