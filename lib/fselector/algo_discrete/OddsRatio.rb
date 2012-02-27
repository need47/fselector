#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Odds Ratio (Odd)
#
#                P(f|c) * (1 - P(f|c'))     tpr * (1-fpr)
#     Odd(f,c) = ----------------------- = ---------------
#                (1 - P(f|c)) * P(f|c')     (1-tpr) * fpr
#     
#                 A*D
#              = -----
#                 B*C
#
# ref: [Wikipedia][wiki] and [An extensive empirical study of feature selection
#       metrics for text classification][url1] and [Optimally Combining Positive
#       and Negative Features for Text Categorization][url2]
# [wiki]: http://en.wikipedia.org/wiki/Odds_ratio
# [url1]: http://dl.acm.org/citation.cfm?id=944974
# [url2]: http://www.site.uottawa.ca/~nat/Workshop2003/zheng.pdf
#
  class OddsRatio < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = (a*d) / (b*c)
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::Odd instead of FSelector::OddsRatio
  Odd = OddsRatio
  
  
end # module
