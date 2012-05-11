#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
#  base alogrithm for discrete feature
#
#     many algos are based on the following 2 x 2 contingency table
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
    
    
    # overload clear\_vars for BaseDiscrete
    def clear_vars
      super
      
      @A, @B, @C, @D = nil, nil, nil, nil
    end # clear_vars
    
    
  end # class


end # module
