#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Sensitivity (SN)
#
#             TP        A
#     SN = ------- = -----
#            TP+FN     A+C
#  
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Sensitivity_and_specificity)
#
  class Sensitivity < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, c = get_A(f, k), get_C(f, k)
        
        s =0.0
        if not (a+c).zero?
          s = a/(a+c)
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  
  # shortcut so that you can use FSelector::SN instead of FSelector::Sensitivity
  SN = Sensitivity
  # Sensitivity, also known as Recall
  Recall = Sensitivity
  
  
end # module
