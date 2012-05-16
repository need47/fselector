#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Kullback-Leibler Divergence (KLD) for discrete feature
#
#     w_i = wbar_i / ( -Z * sigma_j ( P(a_ij) logP(a_ij) ) )
#
#     where wbar(i) = sigma_j ( P(a_ij) KL(C|a_ij) )
#
#           KL(C|a_ij) = sigma_c ( P(c|a_ij) log(P(c|a_ij)/P(c)) )
#
#           Z is normalization constant
#
# ref: [Calculating Feature Weights in Naive Bayes with Kullback-Leibler Measure](http://ix.cs.uoregon.edu/~dou/research/papers/icdm11_fw.)
#
  class KLDivergence < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
        
    private    
    
    # calculate contribution of each feature (f) across all classes 
    # note the normalization constant Z is ignored, since we need only 
    # the relative feature scores
    def calc_contribution(f)
      cv = get_class_labels
      fv = get_feature_values(f, :include_missing_values)
      sz = cv.size.to_f # also equal fv.size
      
      s, w_avg, d = 0.0, 0.0, 0.0
      
      fv.uniq.each do |x|
        px = fv.count(x)/sz
        d += -1.0 * px * Math.log2(px)
        
        kl_x = 0.0
        
        cv.uniq.each do |y|
          py = cv.count(y)/sz
          
          indices = (0...fv.size).to_a.select { |i| fv[i] == x }
          pyx = cv.values_at(*indices).count(y)/indices.size.to_f
          
          kl_x += pyx * Math.log2(pyx/py) if not pyx.zero?
        end
        
        w_avg += px * kl_x
      end
      
      s = w_avg / d if not d.zero?
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::KLD instead of FSelector::KLDivergence
  KLD = KLDivergence
  
  
end # module
