#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Correlation-based Feature Selection (CFS) algorithm for continuous feature (CFS\_c). 
# For CFS\_c, use **select\_feature!** for feature selection
#
# ref: [Feature Selection for Discrete and Numeric Class Machine Learning](http://www.cs.waikato.ac.nz/ml/publications/1999/99MH-Feature-Select.pdf)
#
  class CFS_c < BaseCFS
    # include normalizer and discretizer
    include Normalizer
    include Discretizer
    
    private
    
    
    # replace missing values with mean feature value
    def handle_missing_values
      replace_by_mean_value!
    end
    
        
    # calc the feature-class correlation of two vectors
    def do_rcf(cv, fv)
      # weighted pearson's correlation as cv (class label) contains discrete data
      r = 0.0
      
      cv.uniq.each do |k|
        v = []
        p = cv.count(k)/cv.size.to_f
        
        cv.each do |c|
          if c == k
            v << 1
          else
            v << 0
          end
        end
        
        r += p*v.pearson_r(fv)
      end
      
      r
    end # do_rcf
    
    
    # calc the feature-feature correlation of two vectors
    def do_rff(fv, sv)
      fv.pearson_r(sv) # use pearson's correlation coefficient
    end # do_rff
    
    
  end # class
  
  
end # module
