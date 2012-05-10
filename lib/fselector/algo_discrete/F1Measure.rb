#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# F1-Measure (F1)
#
#           2 * recall * precision
#     F1 = ------------------------
#              recall + precison
#     
#                2 * tp               2 * A
#        = ------------------- = --------------
#           tp + fn + tp + fp     A + C + A + B
#
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class F1Measure < BaseDiscrete
    # this algo generates weight for each feature
    @algo_type = :feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c = get_A(f, k), get_B(f, k), get_C(f, k)
      
        s = 0.0
        x = a+c+a+b
        
        s = 2*a / x if not x.zero?
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  # shortcut so that you can use FSelector::F1 instead of FSelector::F1Measure
  F1 = F1Measure
  
  
end # module
