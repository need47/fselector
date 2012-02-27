#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Document Frequency (DF)
#
#     DF = tp+fp = (A+B)
#
# ref: [An extensive empirical study of feature selection metrics
#      for text classification] (http://dl.acm.org/citation.cfm?id=944974)
#
  class DocumentFrequency < BaseDiscrete
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b = get_A(f, k), get_B(f, k)
        
        s = a + b
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::DF instead of FSelector::DocumentFrequency
  DF = DocumentFrequency
  
  
end # module