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
    # include Entropy module
    include Entropy

    private
  
    # calculate contribution of each feature (f) across all classes
    # see entropy-related functions in BaseDiscrete
    def calc_contribution(f)
      # cache H(c)
      if not @hc
        cv = get_class_labels
        @hc = get_marginal_entropy(cv)
      end
      
      # H(c|f)
      # collect class labels (cv) and feature values (fv)
      cv = get_class_labels
      fv = get_feature_values(f, :include_missing_values)
      hcf = get_conditional_entropy(cv, fv)
      
      # information gain
      s =  @hc - hcf
      
      set_feature_score(f, :BEST, s)      
    end # calc_contribution 
        
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::IG instead of FSelector::InformationGain
  IG = InformationGain
  
  
end # module
