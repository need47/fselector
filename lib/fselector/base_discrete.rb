#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
#  base ranking alogrithm for handling discrete feature
#
#     2 x 2 contingency table
#     
#           c   c'
#         ---------
#      f  | A | B | A+B
#         |---|---| 
#      f' | C | D | C+D
#         ---------
#          A+C B+D  N = A+B+C+D
#     
#      P(f)     = (A+B)/N
#      P(f')    = (C+D)/N
#      P(c)     = (A+C)/N
#      P(c')    = (B+D)/N
#      P(f,c)   = A/N
#      P(f,c')  = B/N
#      P(f',c)  = C/N
#      P(f',c') = D/N
#      P(f|c)   = A/(A+C)
#      P(f|c')  = B/(B+D)
#      P(f'|c)  = C/(A+C)
#      P(f'|c') = D/(B+D)
#
  class BaseDiscrete < Base
    # initialize from an existing data structure
    def initialize(data=nil)
      super(data)
    end

    private
    
    # count of sample (i.e. 'A' or CT00) that
    # contains feature (f = v) and belongs to class (k)
    def get_Av(f, k, v)
      @Av ||= calc_Av
      a = @Av[k][f][v]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      #a+=0.5 if a.zero?
      
      a
    end
    
    
    # pre-compute 'A' or CT00
    # feature (f) has categorical values
    def calc_Av
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          get_feature_values(f).each do |v|
            count = 0.0

            each_sample do |k2, s|
              if k2 == k1
                count += 1 if s.has_key? f and s[f] == v
              end
            end
            
            results[k1][f][v] = count
          end
        end
      end
      
      results
      
    end

    
    # count of sample (i.e. 'B' or CT01) that
    # contains feature (f = v) but does not belong to class (k)
    def get_Bv(f, k, v)
      @Bv ||= calc_Bv
      b = @Bv[k][f][v]
            
      # add 0.5 to avoid any ZERO in denominator or numerator
      #b+=0.5 if b.zero?
      
      b
    end
    
    
    # pre-compute 'B' or CT01
    # feature (f) has categorical values
    def calc_Bv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          get_feature_values(f).each do |v|
            count = 0.0
            
            each_sample do |k2, s|
              if k2 != k1
                count += 1 if s.has_key? f and s[f] == v
              end
            end
          
            results[k1][f][v] = count
          end
        end
      end
      
      results
    end


    # count of sample (i.e. 'C' or CT10) that
    # does not contain feature (f != v) but belongs to class (k)
    def get_Cv(f, k, v)
      @Cv ||= calc_Cv
      c = @Cv[k][f][v]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      #c+=0.5 if c.zero?
      
      c
    end
    
  
    # pre-compute 'C' or CT10
    # feature (f) has categorical values
    def calc_Cv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          get_feature_values(f).each do |v|
            count = 0.0
          
            each_sample do |k2, s|
              if k2 == k1
                count += 1 if not s.has_key? f or s[f] != v
              end
            end
          
            results[k1][f][v] = count
          end
        end
      end
      
      results
    end


    # count of sample (i.e. 'D' or CT11) that
    # does not contain feature (f) and does not belong to class (c)
    def get_Dv(f, k, v)
      @Dv ||= calc_Dv
      d = @Dv[k][f][v]
           
      # add 0.5 to avoid any ZERO in denominator or numerator
      #d+=0.5 if d.zero?
      
      d
    end

    
    # pre-compute 'D' or CT11
    # feature (f) has categorical values
    def calc_Dv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          get_feature_values(f).each do |v|
            count = 0.0
          
            each_sample do |k2, s|
              if k2 != k1
                count += 1 if not s.has_key? f or s[f] != v
              end
            end
          
            results[k1][f][v] = count
          end
        end
      end
      
      results
    end
    
    
    # count of sample (i.e. 'A') that
    # contains feature (f) and belongs to class (k)
    def get_A(f, k)
      @A ||= calc_A
      a = @A[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      a+=0.5 if a.zero?
      
      a 
    end

    
    # pre-compute 'A'
    def calc_A
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          count = 0.0
          
          each_sample do |k2, s|
            if k2 == k1
              count += 1 if s.has_key? f
            end
          end
          
          results[k1][f] = count
        end
      end
      
      results
    end
    
  
    # count of sample (i.e. 'B') that
    # contains feature (f) but does not belong to class (k)
    def get_B(f, k)
      @B ||= calc_B
      b = @B[k][f]
          
      # add 0.5 to avoid any ZERO in denominator or numerator
      b+=0.5 if b.zero?
      
      b
    end
    
    
    # pre-compute 'B'
    def calc_B
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          count = 0.0
          
          each_sample do |k2, s|
            if k2 != k1
              count += 1 if s.has_key? f
            end
          end
          
          results[k1][f] = count
        end
      end
      
      results
    end
    
    
    # count of sample (i.e. 'C') that
    # does not contain feature (f) but belongs to class (k)
    def get_C(f, k)
      @C ||= calc_C
      c = @C[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      c+=0.5 if c.zero?
      
      c
    end
    
  
    # pre-compute 'C'
    def calc_C
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          count = 0.0
          
          each_sample do |k2, s|
            if k2 == k1
              count += 1 if not s.has_key? f
            end
          end
          
          results[k1][f] = count
        end
      end
      
      results
    end
    
    
    # count of sample (i.e. 'D') that
    # does not contain feature (f) and does not belong to class (c)
    def get_D(f, k)
      @D ||= calc_D
      d = @D[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      d+=0.5 if d.zero?
      
      d
    end

    
    # pre-compute 'D'
    def calc_D
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          count = 0.0
          
          each_sample do |k2, s|
            if k2 != k1
              count += 1 if not s.has_key? f
            end
          end
          
          results[k1][f] = count
        end
      end
      
      results
    end
    
    
    #
    # entropy-related function
    #
    
    # H(c) = -1 * sigma_i (P(ci) logP(ci))
    def get_Hc
      if not @hc
        hc = 0.0
        n = get_sample_size.to_f
        
        each_class do |k|
          nk = get_data[k].size
          p = nk/n
          
          if p.zero?
            hc += -0.0
          else
            hc += -1.0 * (p * Math.log2(p))
          end
        end
        
        @hc = hc
      end
      
      @hc
    end
    
    
    # H(c|f) = sigma_j (P(fj)*H(c|fj))
    # H(c|fj) = -1 * sigma_k (P(ck|fj) logP(ck|fj))
    def get_Hcf(f)
      hcf = 0.0
      n = get_sample_size.to_f
      
      # missing values for each class
      m = {}
      
      fvs = get_feature_values(f).uniq
      each_class do |k|
        nk = get_data[k].size.to_f
        nv = 0.0
        
        fvs.each do |v|
          a, b = get_Av(f, k, v), get_Bv(f, k, v)
          nv += a
          
          p1 = (a+b)/n
          p2 = a/(a+b)          
          
          if p2.zero?
            hcf += -0.0
          else
            hcf += -1.0 * p1 * (p2 * Math.log2(p2))
          end
        end
        
        m[k] = nk - nv
      end
      
      # handle missing values of feature (f)
      sm = m.values.sum
      p3 = sm/n
      
      if not sm.zero?
        m.each do |k, i|
          p4 = i/sm
          
          if p4.zero?
            hcf += -0.0
          else
            hcf += -1.0 * p3 * (p4 * Math.log2(p4))
          end
        end
      end
      
      hcf
    end
    
    
    # H(f) = -1 * sigma_i (P(fi) logP(fi))
    def get_Hf(f)
      hf = 0.0
      n = get_sample_size.to_f
      
      fvs = get_feature_values(f)
      fvs.uniq.each do |v|
        p = fvs.count(v)/n
        
        if p.zero?
          hf += -0.0
        else
          hf += -1.0 * (p * Math.log2(p))
        end
      end
      
      # handle missing values of feature (f)
      p1 = (n-fvs.size)/n

      if p1.zero?
        hf += -0.0
      else
        hf += -1.0 * (p1 * Math.log2(p1))
      end
      
      hf
    end
       
    
    # H(f|c) = sigma_j (P(cj) * H(f|cj))
    # H(f|cj) = -1 * sigma_k (P(fk|cj) logP(fk|cj))
    def get_Hfc(f)
      hfc = 0.0
      n = get_sample_size.to_f
      
      each_class do |k|
        nk = get_data[k].size.to_f
        p0 = nk/n
        
        fvs = get_feature_values(f, k)        
        fvs.uniq.each do |v|
          a = get_Av(f, k, v)          
          p1 = a/nk
          
          if p1.zero?
            hfc += -0.0
          else
            hfc += -1.0 * p0 * (p1 * Math.log2(p1))
          end          
        end
        
        # handle missing values of feature (f) in class k
        p2 = (nk-fvs.size)/nk
        if p2.zero?
          hfc += -0.0
        else
          hfc += -1.0 * p0 * (p2 * Math.log2(p2))
        end
      end
      
      hfc
    end
    
    
  end # class


end # module
