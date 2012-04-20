#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# between-within classes sum of squares (BSS/WSS) for continous feature
# 
#                   sigma_i sigma_k I(y_i=k)(xbar_k - xbar)^2
#     BSS_WSS(f) = ----------------------------------------------
#                     sigma_i sigma_k I(y_i=k)(x_i - xbar_k)^2
#
#     where I(y_i=k) is a indicator function with value of 0 or 1
#           xbar_k is the sample mean of class k
#           xbar is the overall sample mean
#           x_i is the value of sample i
#           y_i is the class label of sample i
#
# ref: [Comparison of Discrimination Methods for the Classification of Tumors Using Gene Expression Data](http://amstat.tandfonline.com/doi/abs/10.1198/016214502753479248)
#
  class BetweenWithinClassesSumOfSquare < BaseContinuous
        
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      xbar = get_feature_values(f).mean
      
      a, b, s = 0.0, 0.0, 0.0
      
      k2xbar = {} # cache
      each_class do |k|
        k2xbar[k] = get_feature_values(f, nil, k).mean # w/o missing values
      end
      
      each_sample do |k, sam|
        xbar_k = k2xbar[k]
        a += (xbar_k - xbar)**2
        
        if sam.has_key? f
          x_i = sam[f]
          b += (x_i - xbar_k)**2
        end
      end
      
      s = a/b if not b.zero?
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::BSS_WSS instead of FSelector::BetweenWithinClassesSumOfSquare
  BSS_WSS = BetweenWithinClassesSumOfSquare
  
  
end # module
