#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Accuracy (Acc)
#
#               tp+tn          A+D
#     Acc = ------------- = ---------
#            tp+fn+tn+fp     A+B+C+D
#
  class Accuracy < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        n = a+b+c+d
        
        s = 0.0
        if not n.zero?
          s = (a+d) / n
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::Acc instead of FSelector::Accuracy
  Acc = Accuracy
  
  
end # module