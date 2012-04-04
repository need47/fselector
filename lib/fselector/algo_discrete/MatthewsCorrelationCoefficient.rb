#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Matthews Correlation Coefficient (MCC)
#  
#                            tp*tn - fp*fn
#     MCC = ---------------------------------------------- = PHI = sqrt(CHI/N)
#            sqrt((tp+fp) * (tp+fn) * (tn+fp) * (tn+fn) )
#     
#                          A*D - B*C
#         = -------------------------------------
#           sqrt((A+B) * (A+C) * (B+D) * (C+D))
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Matthews_correlation_coefficient)
#
  class MatthewsCorrelationCoefficient < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = 0.0
        if not ((a+b)*(a+c)*(b+d)*(c+d)).zero?     
          s = (a*d-b*c) / Math.sqrt((a+b)*(a+c)*(b+d)*(c+d))
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::MCC instead of FSelector::MatthewsCorrelationCoefficient
  MCC = MatthewsCorrelationCoefficient
  # Matthews Correlation Coefficient (MCC), also known as Phi coefficient 
  PHI = MatthewsCorrelationCoefficient
  
  
end # module
