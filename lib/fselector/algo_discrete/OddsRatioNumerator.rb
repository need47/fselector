#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Odds Ratio Numerator (OddN)
#
#     OddN(f,c) = P(f|c) * (1 - P(f|c')) =  tpr * (1-fpr)
#     
#                   A           B          A * D
#               = ---- * (1 - ----) = ---------------
#                  A+C         B+D     (A+C) * (B+D)
#
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class OddsRatioNumerator < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = 0.0
        x = (a+c)*(b+d)
        
        s = a*d/x if not x.zero?
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::OddN instead of FSelector::OddsRatioNumerator
  OddN = OddsRatioNumerator
  
  
end # module
