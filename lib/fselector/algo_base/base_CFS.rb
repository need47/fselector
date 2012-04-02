#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# base class for Correlation-based Feature Selection (CFS) algorithm, see specialized
# versions for discrete feature (CFS_d) and continuous feature (CFS_c), respectively
#
# @note for simplicity, we use *sequential forward search* for optimal feature subset,
# the original CFS that uses *best first search* only produces slightly better results
# but demands much more computational resources
#
# ref: [Feature Selection for Discrete and Numeric Class Machine Learning](http://www.cs.waikato.ac.nz/ml/publications/1999/99MH-Feature-Select.pdf)
#
  class BaseCFS < Base
    # undefine superclass methods
    undef :select_feature_by_score!
    undef :select_feature_by_rank!
    
    private
    
    # use sequential forward search
    def get_feature_subset
      subset = []
      feats = get_features.dup
	  
	    s_best = -100.0
      # use cache
      @rcf_best, @rff_best = 0.0, 0.0
	  
      improvement = true
      
      while improvement
        improvement = false
        f_max, s_max = nil, -100.0
        rcf_max, rff_max = -100.0, -100.0
        
        feats.each do |f|
          s_try, rcf_try, rff_try = calc_merit(subset, f)
          
          if s_try > s_best and s_try > s_max
            f_max, s_max = f, s_try
            rcf_max, rff_max = rcf_try, rff_try
          end
        end
        
        # add f_max to subset and remove it from feats
        if f_max
          subset << f_max
          feats.delete(f_max)
          improvement = true
          # update info
          s_best, @rcf_best, @rff_best = s_max, rcf_max, rff_max
        end
      end
      
      subset
    end # get_feature_subset
    
    
    # calc new merit of subset when adding feature (f)
    def calc_merit(subset, f)
      k = subset.size.to_f + 1
      
      # use cache
      rcf = @rcf_best + calc_rcf(f)
      rff = @rff_best      
      subset.each do |s|
        rff += 2*calc_rff(f, s)
      end
      
      m = rcf/Math.sqrt(k+rff)
      
      [m, rcf, rff]
    end # calc_metrit
       
    
	  # calc feature-class correlation
    def calc_rcf(f)
	    @f2rcf ||= {} # use cache
	    
	    if not @f2rcf.has_key? f
	      cv = get_class_labels
	      fv = get_feature_values(f, :include_missing_values)
	      @f2rcf[f] = do_rcf(cv, fv)
	    end
	    
	    @f2rcf[f]
    end # calc_rcf
    
    
    # calc feature-feature intercorrelation
    def calc_rff(f, s)
	    @fs2rff ||= {} # use cache
	    
	    if not @f2idx
	      @f2idx = {}
	      fvs = get_features
		    fvs.each_with_index { |f, idx| @f2idx[f] = idx }
	    end
	    
	    if @f2idx[f] > @f2idx[s]
	      k = [f, s].join('_')
	    else
	      k = [s, f].join('_')
	    end
	    
	    if not @fs2rff.has_key? k
	      fv = get_feature_values(f, :include_missing_values)
	      sv = get_feature_values(s, :include_missing_values)
	      @fs2rff[k] = do_rff(fv, sv)
	    end
	    
	    @fs2rff[k]
    end # calc_rff
    
	
	  # calc the feature-class correlation of two vectors
    def do_rcf(cv, fv)
      abort "[#{__FILE__}@#{__LINE__}]: "+
             "derived CFS algo must implement its own do_rcf()"
    end # do_rcf
    
    
    # calc the feature-class correlation of two vectors
    def do_rff(fv, sv)
      abort "[#{__FILE__}@#{__LINE__}]: "+
             "derived CFS algo must implement its own do_rff()"
    end # do_rff
    
    
  end # class
  
  
end # module
