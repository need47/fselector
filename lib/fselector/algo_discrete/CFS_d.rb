#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Correlation-based Feature Selection (CFS) algorithm for discrete feature (CFS\_d). 
# For CFS\_d, use **select\_feature!** for feature selection
#
# ref: [Feature Selection for Discrete and Numeric Class Machine Learning](http://www.cs.waikato.ac.nz/ml/publications/1999/99MH-Feature-Select.pdf)
#
  class CFS_d < BaseCFS
    # include Entropy module
    include Entropy
    
    private
    
    # replace missing values with most seen feature value
    def handle_missing_values
      replace_by_most_seen_value!
    end
    
        
    # calc the feature-class correlation of two vectors
    def do_rcf(cv, fv)
      hc = get_marginal_entropy(cv)
      hf = get_marginal_entropy(fv)
      hcf = get_conditional_entropy(cv, fv)
      
      # symmetrical uncertainty
      2*(hc-hcf)/(hc+hf)
    end # do_rcf
    
    
    # calc the feature-feature correlation of two vectors
    def do_rff(fv, sv)
      hf = get_marginal_entropy(fv)
      hs = get_marginal_entropy(sv)
      hfs = get_conditional_entropy(fv, sv)
      
      # symmetrical uncertainty
      2*(hf-hfs)/(hf+hs)
    end # do_rff
    
    
  end # class
  
  
end # module
