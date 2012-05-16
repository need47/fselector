#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Relief algorithm for continuous feature (Relief_c)
#
# @note Relief applicable only to two-class problem without missing data
#
# ref: [The Feature Selection Problem: Traditional Methods and a New Algorithm](http://www.aaai.org/Papers/AAAI/1992/AAAI92-020.pdf)
#
  class Relief_c < BaseRelief    
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
       
    private
    
    # difference beween the feature (f) of two samples
    # specialized version for continuous feature
    def diff_feature(f, s1, s2)
      if not s1.has_key?(f) or not s2.has_key?(f)
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  Relief does not allow missing values"
      end
      
      nu = get_normalization_unit(f)
      
      (nu.zero?) ? 0.0 : (s1[f]-s2[f])/nu
    end # diff_feature
    
    
    # get normalization unit for each feature
    def get_normalization_unit(fi)
      return @f2nu[fi] if @f2nu
      
      @f2nu = {}
      
      each_feature do |f|
        fvs = get_feature_values(f)
        @f2nu[f] = (fvs.max-fvs.min).to_f
      end
      
      @f2nu[fi]
    end # get_normalization_unit
    
    
    # override clear\_vars for Relief_c
    def clear_vars
      super
      
      @f2nu = nil
    end # clear_vars
    
    
  end # class
  
  
end # module