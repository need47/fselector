#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Information Gain for feature with discrete data (IG)
#
#     IG_d(c,f) = H(c) - H(c|f)
#     
#     where H(c) = -1 * sigma_i (P(ci) logP(ci))
#           H(c|f) = sigma_j (P(fj)*H(c|fj))
#           H(c|fj) = -1 * sigma_k (P(ck|fj) logP(ck|fj))
#
# ref: [Using Information Gain to Analyze and Fine Tune the Performance of Supply Chain Trading Agents](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.141.7895)
#
  class InformationGain < BaseDiscrete

    private
  
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      # H(c)
      hc = 0.0
      n = get_sample_size.to_f
      
      each_class do |k|
        nk = get_data[k].size
        p1 = nk/n

        if p1.zero?
          hc += -0.0
        else
          hc += -1.0 * ( p1 * Math.log2(p1) )
        end
      end
      
      # H(c|f)
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
      
      # IG
     s =  hc - hcf
     
     set_feature_score(f, :BEST, s)      
    end # calc_contribution
    
      	
  end # class 
 
    
  # shortcut so that you can use FSelector::IG instead of FSelector::InformationGain
  IG = InformationGain
  
  
end # module
