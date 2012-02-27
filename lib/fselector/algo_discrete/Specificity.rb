#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Specificity (SP)
#
#             TN        D
#     SP  = ------- = -----
#            TN+FP     B+D
#
  class Specificity < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        b, d = get_B(f, k), get_D(f, k)
        
        s = d/(b+d)
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::SP instead of FSelector::Specificity
  SP = Specificity
  
  
end # module
