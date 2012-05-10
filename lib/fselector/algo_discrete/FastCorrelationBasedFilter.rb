#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Fast Correlation-Based Filter (FCBF) for discrete feature, 
# use **select\_feature!** for feature selection
#
# ref: [Feature Selection for High-Dimensional Data: A Fast Correlation-Based Filter Solution](http://www.hpl.hp.com/conferences/icml2003/papers/144.pdf)
#
  class FastCorrelationBasedFilter < BaseDiscrete
    # include Entropy module
    include Entropy
    
    # this algo selects a subset of feature
    @algo_type = :feature_subset_selection
    
    #
    # initialize from an existing data structure
    #
    # @param [Float] delta predefined threshold
    #
    def initialize(delta=0.0, data=nil)
      super(data)
      @delta = delta || 0.0
    end
    
    private
    
    # Fast Correlation-Based Filter(FCBF) algorithm
    def get_feature_subset
      # feature subset
      subset = []
      
      # step 1: calc SU(i,c) for each feature
      f2su = {}
      get_features.each do |f|
        su = get_SU_fc(f)
        f2su[f] = su
        if su >= @delta
          subset << f
        end
      end
      
      # step 2: order subset by decreasing feature SU of
      subset = subset.sort { |x,y| f2su[y] <=> f2su[x] }
      
      # step 3: main algo
      fp = subset.first
      while fp
        fq = get_next_element(subset, fp)
        
        while fq
          su_pq = get_SU_pq(fp, fq)
          
          if su_pq >= f2su[fq]
            fq_new = get_next_element(subset, fq)
            subset.delete(fq) #remove fq
            fq = fq_new
          else
            fq = get_next_element(subset, fq)
          end
        end
        
        fp = get_next_element(subset, fp)
      end
      
      subset
    end # get_feature_subset
    
    
    # SU(X,Y) = 2 * ( H(X)-H(X|Y) ) / ( H(X)+H(Y) )
    def get_SU_fc(f)
      cv = get_class_labels
      fv = get_feature_values(f, :include_missing_values)
      
      # Hf
      hf = get_marginal_entropy(fv)
      # cache for future use
      @f2hf ||= {}
      @f2hf[f] = hf
      
      # Hfc
      hfc = get_conditional_entropy(fv, cv)
      
      # Hc
      hc = get_marginal_entropy(cv)
      
      2.0*(hf-hfc)/(hf+hc)
    end
    
    
    def get_SU_pq(p, q)
      # Hp, use cache
      hp = @f2hf[p]
      
      # Hpq
      # H(p|q) = sigma_j (P(qj) H(p|qj))
      # H(p|qj) = -1 * sigma_k (P(pk|qj) logP(pk|qj))
      pv = get_feature_values(p, :include_missing_values)
      qv = get_feature_values(q, :include_missing_values)
      hpq = get_conditional_entropy(pv, qv)
      
      # Hq, use cache
      hq = @f2hf[q]
      
      2.0*(hp-hpq)/(hp+hq)
    end
    
    
    def get_next_element(subset, fp)
      fq = nil
      
      subset.each_with_index do |v, i|
        if v == fp and i+1 < subset.size
          fq = subset[i+1]
          break
        end
      end
      
      fq
    end
    
     
  end # class 
 
    
  # shortcut so that you can use FSelector::FCBF instead of FSelector::FastCorrelationBasedFilter
  FCBF = FastCorrelationBasedFilter
  
  
end # module
