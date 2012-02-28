#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Accuracy Balanced (Acc2)
#
#     Acc2 = |tpr - fpr| = |A/(A+C) - B/(B+D)|
#
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class AccuracyBalanced < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = (a/(a+c) - b/(b+d)).abs
        
        set_feature_score(f, k, s)
      end
    end
    
    
  end
  
  
  # shortcut so that you can use FSelector::Acc2 instead of FSelector::AccuracyBalanced
  Acc2 = AccuracyBalanced
  
  
end
