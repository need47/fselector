#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Precision
#
#                   TP        A
#     Precision = ------- = -----
#                  TP+FP     A+B
#
  class Precision < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b = get_A(f, k), get_B(f, k)
        
        s = a/(a+b)
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
end # module
