#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Information Gain (IG) for discrete feature
#
#     IG = H(C) - H(C|F)
#     
#     where H(C) = -1 * sigma_i (P(c_i) log2 P(c_i))
#           H(C|F) = sigma_j (P(f_j)*H(C|f_j))
#           H(C|f_j) = -1 * sigma_k (P(c_k|f_j) log2 P(c_k|f_j))
#
# ref: [Using Information Gain to Analyze and Fine Tune the Performance of Supply Chain Trading Agents](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.141.7895)
#
  class InformationGain < BaseDiscrete
    # include Entropy module
    include Entropy

    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
    private
  
    # calculate contribution of each feature (f) across all classes
    # see entropy-related functions in BaseDiscrete
    def calc_contribution(f)
      # cache H(c), frequently used
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
    
    
    # override clear\_vars for InformationGain
    def clear_vars
      super
      
      @hc = nil
    end # clear_vars
    
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::IG instead of FSelector::InformationGain
  IG = InformationGain
  
  
end # module
