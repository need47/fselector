#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# F-test (FT) based on F-statistics for continuous feature
# 
#           between-group variability
#     FT = ---------------------------
#           within-group variability
#
#           sigma_k n_k*(ybar_k - ybar)^2 / (K-1)
#        = --------------------------------------
#           sigma_ik (y_ik - ybar_k)^2 / (N-K)
#
#     where n_k is the sample size of class k
#           ybar_k is the sample mean of class k
#           ybar is the overall smaple mean
#           K is the number of classes
#           y_ik is the value of sample i of class k
#           N is the overall sample size
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/F-test#Formula_and_calculation) and [Minimum redundancy feature selection from microarray gene expression data](http://penglab.janelia.org/papersall/docpdf/2004_JBCB_feasel-04-06-15.pdf)
#
  class FTest < BaseContinuous
        
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution2(f)
      a, b, s = 0.0, 0.0, 0.0
      ybar = get_feature_values(f).mean
      kz = get_classes.size.to_f
      sz = get_sample_size.to_f
      
      k2ybar = {} # cache
      each_class do |k|
        k2ybar[k] = get_feature_values(f, nil, k).mean        
      end
      
      # a
      each_class do |k|
        n_k = get_data[k].size.to_f
        a += n_k * (k2ybar[k] - ybar)**2 / (kz-1)
      end
      
      # b
      each_sample do |k, s|
        if s.has_key? f
          y_ik = s[f]
          b += (y_ik - k2ybar[k])**2 / (sz-kz)
        end
      end
      
      s = a/b if not b.zero?
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    def calc_contribution(f)
      a, b, s = 0.0, 0.0, 0.0
      ybar = get_feature_values(f).mean
      kz = get_classes.size.to_f
      sz = get_sample_size.to_f
      
      k2ybar = {} # cache
      each_class do |k|
        k2ybar[k] = get_feature_values(f, nil, k).mean        
      end
      
      # a
      each_class do |k|
        n_k = get_data[k].size.to_f
        a += n_k * (k2ybar[k] - ybar)**2 / (kz-1)
      end
      
      # b
      each_sample do |k, s|
        if s.has_key? f
          y_ik = s[f]
          b += (y_ik - k2ybar[k])**2 / (sz-kz)
        end
      end
      
      s = a/b if not b.zero?
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::FT instead of FSelector::FTest
  FT = FTest
  
  
end # module
