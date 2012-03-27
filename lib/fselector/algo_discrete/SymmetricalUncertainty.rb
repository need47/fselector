#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Symmetrical Uncertainty for feature with discrete data (SU)
#
#                      IG(c|f)       H(c) - H(c|f)
#     SU(c,f) = 2 * ------------- = ---------------
#                    H(c) + H(f)      H(c) + H(f)
#     
#     where H(c) = -1 * sigma_i (P(ci) logP(ci))
#           H(c|f) = sigma_j (P(fj)*H(c|fj))
#           H(c|fj) = -1 * sigma_k (P(ck|fj) logP(ck|fj))
#           H(f) = -1 * sigma_i (P(fi) logP(fi))
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Symmetric_uncertainty)
#
  class SymmetricalUncertainty < BaseDiscrete

    private
  
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      # step 1: H(c)
      hc = 0.0
      n = get_sample_size.to_f
      
      each_class do |k|
        nk = get_data[k].size
        p1 = nk/n

        if p1.zero?
          hc += -0.0
        else
          hc += -1.0 * (p1 * Math.log2(p1))
        end
      end
      
      # step 2: H(c|f)
      hcf = 0.0
      m = {}
      
      each_class do |k|
        nk = get_data[k].size        
        nv = 0.0
        
        fvs = get_feature_values(f).uniq
        fvs.each do |v|
          a, b = get_Av(f, k, v), get_Bv(f, k, v)
          #pp "(v,a,b) => (#{v}, #{a}, #{b})"
          nv += a
          
          p2 = a/(a+b)
          p3 = (a+b)/n
          
          if p2.zero?
            hcf += -0.0
          else
            hcf += -1.0 * p3 * (p2 * Math.log2(p2))
          end           
        end
        
        m[k] = nk - nv
         
      end
      
      # handle empty feature for each class
      sm = m.values.sum
      if not sm.zero?
        #pp m
        m.each do |k, i|
          pm = i/sm
          
          if pm.zero?
            hcf += -0.0
          else
            hcf += -1.0 * (sm/n) * (pm * Math.log2(pm))
          end
        end
      end
      
      # step 3: H(f)
      hf = 0.0
      fvs = get_feature_values(f)
      fvs.uniq.each do |v|
        p4 = fvs.count(v)/n
        if p4.zero?
          hf += -0.0
        else
          hf += -1.0 * (p4 * Math.log2(p4))
        end
      end
      
      # handle empty feature
      p5 = (n-fvs.size)/n
      if p5.zero?
        hf += -0.0
      else
        hf += -1.0 * (p5 * Math.log2(p5))
      end
      
      # step 4: score
      s =  2*(hc-hcf)/(hc+hf)
     
      set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::SU instead of FSelector::SymmetricalUncertainty
  SU = SymmetricalUncertainty
  
  
end # module
