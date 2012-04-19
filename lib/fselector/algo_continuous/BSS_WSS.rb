#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# between-within classes sum of squares (BSS/WSS) for continous feature
# 
#                   sigma_i sigma_k I(yi=k)(xbar_kj - xbar_xj)2
#     BSS_WSS(f) = ----------------------------------------------
#                     sigma_i sigma_k I(yi=k)(x_ij - xbar_kj)2
#
# ref: [Comparison of Discrimination Methods for the Classification of Tumors Using Gene Expression Data](http://amstat.tandfonline.com/doi/abs/10.1198/016214502753479248)
#
  class BetweenWithinClassesSumOfSquare < BaseContinuous
        
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      xbar_xj = get_feature_values(f).mean
      
      a, b, s = 0.0, 0.0, 0.0
      
      each_sample do |k, sam|
        # get the feature values for class k, without missing values
        xbar_kj = get_feature_values(f, nil, k).mean
        a += (xbar_kj - xbar_xj)**2
        
        if sam.has_key? f
          x_ij = sam[f]
          b += (x_ij - xbar_kj)**2
        end
      end
      
      s = a/b if not b.zero?
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::BSS_WSS instead of FSelector::BetweenWithinClassesSumOfSquare
  BSS_WSS = BetweenWithinClassesSumOfSquare
  
  
end # module
