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
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = 0.0
        x = (a+c)*b
        
        s = a * (b+d) / x if not x.zero?
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::PR instead of FSelector::ProbabilityRatio
  PR = ProbabilityRatio
  
  
end # module
