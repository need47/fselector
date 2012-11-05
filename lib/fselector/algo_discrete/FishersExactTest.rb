#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# (two-sided) Fisher's Exact Test (FET)
# 
#             (A+B)! * (C+D)! * (A+C)! * (B+D)!  
#     FET =  -----------------------------------
#                  A! * B! * C! * D!
#     
#     for FET (p-value), the smaller, the better, but we intentionally negate it
#     so that the larger is always the better (consistent with other algorithms)
#     R equivalent: fisher.test
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Fisher\'s_exact_test)
#
  class FishersExactTest < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
       
    private
        
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)     
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        # note: intentionally negated it
        R.eval "rv <- fisher.test(matrix(c(#{a}, #{b}, #{c}, #{d}), nrow=2))$p.value"
        s = -1.0 * R.rv
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::FET instead of FSelector::FishersExactTest
  FET = FishersExactTest
  
  
end # module
