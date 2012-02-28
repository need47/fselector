#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Probability Ratio (PR)
#
#     PR = tpr / fpr
#     
#           A/(A+C)    A * (B+D)
#        = -------- = -----------
#           B/(B+D)    (A+C) * B
#
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class ProbabilityRatio < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = a * (b+d) / (a+c) / b
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::PR instead of FSelector::ProbabilityRatio
  PR = ProbabilityRatio
  
  
end # module
