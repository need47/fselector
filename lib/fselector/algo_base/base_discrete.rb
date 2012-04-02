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
        
    # count of sample (i.e. 'A') that
    # contains feature (f) and belongs to class (k)
    def get_A(f, k)
      @A ||= calc_A
      a = @A[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      a+=0.5 if a.zero?
      
      a 
    end # get_A

    
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
    end # calc_A
    
  
    # count of sample (i.e. 'B') that
    # contains feature (f) but does not belong to class (k)
    def get_B(f, k)
      @B ||= calc_B
      b = @B[k][f]
          
      # add 0.5 to avoid any ZERO in denominator or numerator
      b+=0.5 if b.zero?
      
      b
    end # get_B
    
    
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
    end # calc_B
    
    
    # count of sample (i.e. 'C') that
    # does not contain feature (f) but belongs to class (k)
    def get_C(f, k)
      @C ||= calc_C
      c = @C[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      c+=0.5 if c.zero?
      
      c
    end # get_C
    
  
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
    end # calc_C
    
    
    # count of sample (i.e. 'D') that
    # does not contain feature (f) and does not belong to class (c)
    def get_D(f, k)
      @D ||= calc_D
      d = @D[k][f]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      d+=0.5 if d.zero?
      
      d
    end # get_D

    
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
    end # calc_D
    
    
    # count of sample (i.e. 'A' or CT00) that
    # contains feature (f = v) and belongs to class (k)
    def get_Av(f, k, v)
      @Av ||= calc_Av
      a = @Av[k][f][v]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      #a+=0.5 if a.zero?
      
      a
    end # get_Av
    
    
    # pre-compute 'A' or CT00
    # feature (f) has categorical values
    def calc_Av
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          fvs = get_feature_values(f).uniq
          fvs.each do |v|
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
      
    end # calc_Av

    
    # count of sample (i.e. 'B' or CT01) that
    # contains feature (f = v) but does not belong to class (k)
    def get_Bv(f, k, v)
      @Bv ||= calc_Bv
      b = @Bv[k][f][v]
            
      # add 0.5 to avoid any ZERO in denominator or numerator
      #b+=0.5 if b.zero?
      
      b
    end # get_Bv
    
    
    # pre-compute 'B' or CT01
    # feature (f) has categorical values
    def calc_Bv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          fvs = get_feature_values(f).uniq
          fvs.each do |v|
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
    end # calc_Bv


    # count of sample (i.e. 'C' or CT10) that
    # does not contain feature (f != v) but belongs to class (k)
    def get_Cv(f, k, v)
      @Cv ||= calc_Cv
      c = @Cv[k][f][v]
      
      # add 0.5 to avoid any ZERO in denominator or numerator
      #c+=0.5 if c.zero?
      
      c
    end # get_Cv
    
  
    # pre-compute 'C' or CT10
    # feature (f) has categorical values
    def calc_Cv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          fvs = get_feature_values(f).uniq
          fvs.each do |v|
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
    end # calc_Cv


    # count of sample (i.e. 'D' or CT11) that
    # does not contain feature (f) and does not belong to class (c)
    def get_Dv(f, k, v)
      @Dv ||= calc_Dv
      d = @Dv[k][f][v]
           
      # add 0.5 to avoid any ZERO in denominator or numerator
      #d+=0.5 if d.zero?
      
      d
    end # get_Dv

    
    # pre-compute 'D' or CT11
    # feature (f) has categorical values
    def calc_Dv
      results = {}
      
      each_class do |k1|
        results[k1] = {}
        
        each_feature do |f|
          results[k1][f] = {}
          
          fvs = get_feature_values(f).uniq
          fvs.each do |v|
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
    end # calc_Dv
    
    
  end # class


end # module
