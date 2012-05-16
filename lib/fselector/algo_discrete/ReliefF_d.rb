#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
# extended Relief algorithm for discrete feature (ReliefF_d)
#
# @note applicable to multi-class problem with missing data
#
# ref: [Estimating Attributes: Analysis and Extensions of RELIEF](http://www.springerlink.com/content/fp23jh2h0426ww45/)
#
  class ReliefF_d < BaseReliefF
    # include module
    include Discretizer
    
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
       
    private
    
    # difference beween the feature (f) of two samples
    # specialized version for discrete feature
    def diff_feature(f, s1, s2, k1, k2)
      d = 0.0
      
      if s1.has_key?(f) and s2.has_key?(f) # no missing value
        d = (s1[f] == s2[f]) ? 0.0 : 1.0
      elsif not s1.has_key?(f) and not s2.has_key?(f) # two missing values
        fvs = get_feature_values(f).uniq
        fvs.each do |mv|
          d -= calc_p(f, mv, k1)*calc_p(f, mv, k2)
        end
        d += 1
      elsif not s1.has_key?(f) # s1: one missing value
        # diff(f, s1, s2) = 1 - P(value(f, s2)|class(s1))
        d = 1 - calc_p(f, s2[f], k1)
      else # s2: one missing value
        # diff(f, s1, s2) = 1 - P(value(f, s1)|class(s2))
        d = 1 - calc_p(f, s1[f], k2)
      end
      
      d
    end # diff_feature
    
    
  end # class
  
  
end # module