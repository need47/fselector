#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Symmetrical Uncertainty (SU) for discrete feature
#
#                 IG(C|F)       H(C) - H(C|F)
#     SU = 2 * ------------- = ---------------
#               H(C) + H(F)      H(C) + H(F)
#     
#     where H(C) = -1 * sigma_i (P(c_i) log2 P(c_i))
#           H(C|F) = sigma_j (P(f_j)*H(C|f_j))
#           H(C|f_j) = -1 * sigma_k (P(c_k|f_j) log2 P(c_k|f_j))
#           H(F) = -1 * sigma_i (P(f_i) log2 P(f_i))
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Symmetric_uncertainty) and [Robust Feature Selection Using Ensemble Feature Selection Techniques](http://dl.acm.org/citation.cfm?id=1432021)
#
  class SymmetricalUncertainty < BaseDiscrete
    # include Entropy module
    include Entropy

    # this algo generates weight for each feature
    @algo_type = :feature_weighting
    
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
