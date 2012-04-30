#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Gini Index (GI), generalized for multi-class problem
#
#     GI(f) = 1 - sigma_c (P(c|f)^2)
#
# for GI, the smaller, the better, but we intentionally negate it
# so that the larger is always the better (consistent with other algorithms)
#
# ref: [Advancing Feaure Selection Research - ASU Feature Selection Repository](http://featureselection.asu.edu/featureselection_techreport.pdf)
#
  class GiniIndex < BaseDiscrete
          
    private
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      s = 0.0
      
      each_class do |k|
        a, b = get_A(f, k), get_B(f, k)
        x = a+b
        
        s += (a/x)**2 if not x.zero?
      end
      
      # note: we've intentionally negated it
      s = s-1
      s = -0.5 if s.zero? # Gini(max) = 0.5
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::GI instead of FSelector::GiniIndex
  GI = GiniIndex
  
  
end # module
