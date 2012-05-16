#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Relief algorithm for discrete feature (Relief_d)
#
# @note Relief applicable only to two-class problem without missing data
#
# ref: [The Feature Selection Problem: Traditional Methods and a New Algorithm](http://www.aaai.org/Papers/AAAI/1992/AAAI92-020.pdf)
#
  class Relief_d < BaseRelief
    # include module
    include Discretizer
    
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
    private    
    
    # difference beween the feature (f) of two samples
    # specialized version for discrete feature
    def diff_feature(f, s1, s2)
      d = 0.0
      
      if not s1.has_key?(f) or not s2.has_key?(f)
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  Relief does not allow missing values"
      end
      
      (s1[f] == s2[f]) ? 0.0 : 1.0
    end # diff_feature
    
    
  end # class
  
  
end # module
