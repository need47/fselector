#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# GSS coefficient (GSS), a simplified variant of Chi-Squared
# proposed by Galavotti
#
#     GSS(f,c) = P(f,c) * P(f',c') - P(f,c') * P(f',c)
#     
#              = A/N * D/N - B/N * C/N
#
# suitable for large samples and 
# none of the values of (A, B, C, D) < 5
#
# ref: [A Comparative Study on Feature Selection Methods for Drug Discovery](http://pubs.acs.org/doi/abs/10.1021/ci049875d)
#
  class GSSCoefficient < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)    
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        n = a+b+c+d
        
        s = 0.0
        if not n.zero?
          s = a/n * d/n - b/n * c/n
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::GSS instead of FSelector::GSSCoefficient
  GSS = GSSCoefficient
  
  
end # module
