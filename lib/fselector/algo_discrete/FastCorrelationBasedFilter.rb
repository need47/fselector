#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Fast Correlation-Based Filter for feature with discrete data (FCBF)
#
# ref: [Feature Selection for High-Dimensional Data: A Fast Correlation-Based Filter Solution](http://www.hpl.hp.com/conferences/icml2003/papers/144.pdf)
#
  class FastCorrelationBasedFilter < BaseDiscrete
    #
    # initialize from an existing data structure
    #
    # @param [Float] delta predefined threshold.
    #   if not provided, use 1/sqrt(alpha*m) where
    #   alpha is confidence level and m is sample size
    #   respectively.
    #
    def initialize(delta=nil, data=nil)
      super(data)
      @delta = delta || 0.0
    end
    
    # undefine superclass methods
    undef :select_feature_by_score!
    undef :select_feature_by_rank!
    
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
    end
    
    
    # SU(X,Y) = 2 * ( H(X)-H(X|Y) ) / ( H(X)+H(Y) )
    def get_SU_fc(f)   
      # Hf
      hf = get_Hf(f)
      # cache for future use
      @f2hf ||= {}
      @f2hf[f] = hf
      
      # Hfc
      hfc = get_Hfc(f)
      
      # Hc
      hc = get_Hc
      
      2.0*(hf-hfc)/(hf+hc)
    end
    
    
    def get_SU_pq(p, q)
      # Hp, use cache
      hp = @f2hf[p]
      
      # Hpq
      hpq = get_Hpq(p, q)
      
      # Hq, use cache
      hq = @f2hf[q]
      
      2.0*(hp-hpq)/(hp+hq)
    end
    
    
    # H(p|q) = sigma_j (P(qj) H(p|qj))
    # H(p|qj) = -1 * sigma_k (P(pk|qj) logP(pk|qj))
    def get_Hpq(p, q)
      hpq = 0.0
      
      pvs, qvs = get_fv(p), get_fv(q)
      nq = qvs.size.to_f
      
      qvs.uniq.each do |qv|
        p0 = qvs.count(qv)/nq
        
        res = get_pv_at_qv(pvs, qvs, qv)
        np = res.size.to_f
        
        res.uniq.each do |pv|
          p1 = res.count(pv)/np
          
          if p1.zero?
            hpq += -0.0
          else
            hpq += -1.0 * p0 * (p1 * Math.log2(p1))
          end
        end
      end
      
      hpq
    end
    
    
    # collect all pv at i in pvs when qvs[i] == qv
    def get_pv_at_qv(pvs, qvs, qv)
      res = []
      
      pvs.each_with_index do |pv, i|
        res << pv if qvs[i] == qv
      end
      
      res
    end
    
    
    # get values (including missing ones) for feature (f)
    def get_fv(f)
      @f2fv ||= {} # cache
      
      if not @f2fv.has_key? f
        @f2fv[f] = []
        each_sample do |k, s|
          if s.has_key? f
            @f2fv[f] << s[f]
          else
            @f2fv[f] << nil # for missing values
          end
        end      
      end
      
      @f2fv[f]
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
