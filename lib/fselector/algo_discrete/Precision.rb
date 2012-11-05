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
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b = get_A(f, k), get_B(f, k)
        
        s = 0.0
        x = a+b
        
        s = a/x if not x.zero?
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
end # module
