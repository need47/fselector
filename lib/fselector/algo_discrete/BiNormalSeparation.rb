#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Bi-Normal Separation (BNS)
#
#     BNS = |F'(tpr) - F'(fpr)|
#      
#     where F'(x) is normal inverse cumulative distribution function
#     R equivalent: qnorm
# 
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class BiNormalSeparation < BaseDiscrete
        
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = 0.0
        if not (a+c).zero? and not (b+d).zero?
          tpr, fpr = a/(a+c), b/(b+d)
          
          R.eval "rv <- qnorm(#{tpr}) - qnorm(#{fpr})"
          s = R.rv.abs
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::BNS instead of FSelector::BiNormalSeparation
  BNS = BiNormalSeparation
  
  
end # module
