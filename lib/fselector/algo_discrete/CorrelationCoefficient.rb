#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Correlation Coefficient (CC), a variant of CHI, 
# which can be viewed as a one-sided chi-squared metric
#
#                  sqrt(N) * (A*D - B*C)
#     CC = --------------------------------------
#           sqrt( (A+B) * (C+D) * (A+C) * (B+D) )
#
# ref: [Optimally Combining Positive and Negative Features for Text Categorization](http://www.site.uottawa.ca/~nat/Workshop2003/zheng.pdf)
#
  class CorrelationCoefficient < BaseDiscrete
    
    private
        
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        n = a+b+c+d
        
        s = 0.0
        x = (a+b)*(c+d)*(a+c)*(b+d)
        
        if not x.zero?
          s = Math.sqrt(n) * (a*d-b*c) / Math.sqrt(x)
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::CC instead of FSelector::CorrelationCoefficient
  CC = CorrelationCoefficient
  
  
end # module
