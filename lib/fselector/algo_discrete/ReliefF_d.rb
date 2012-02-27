#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
# extended Relief algorithm for discrete feature (ReliefF_d)
#
# @note applicable to multi-class problem with missing data
#
# ref: [Estimating Attributes: Analysis and Extensions of RELIEF][url]
# [url]: http://www.springerlink.com/content/fp23jh2h0426ww45/
#
  class ReliefF_d < BaseDiscrete
    #
    # new()
    #
    # @param [Integer] m number of samples to be used 
    #   for estimating feature contribution. max can be
    #   the number of training samples
    # @param [Integer] k number of k-nearest neighbor
    # @param [Hash] data existing data structure
    #
    def initialize(m=nil, k=10, data=nil)
      super(data)
      @m = m # use all samples
      @k = (k || 10)  # default 10
    end
    
    private
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)      
      score = 0.0
      
      # use all samples if @m not provided
      @m = get_sample_size if not @m
      
      @m.times do
        # pick a sample at random
        rs, rk = pick_a_sample_at_random
        
        # find k nearest neighbor for each class
        nbrs = find_k_nearest_nb(rs, rk)
        
        # calc contribution from neighbors
        score += calc_score(f, rs, rk, nbrs)
      end
      
      s = score / @m
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
    # pick a sample at random
    def pick_a_sample_at_random
      rk = get_classes[rand(get_classes.size)]
      rks = get_data[rk]
      
      [ rks[rand(rks.size)], rk ]
    end # pick_a_sample_at_random
    
    # # find k nearest neighbors of sample (rs) for each class 
    def find_k_nearest_nb(rs, rk)
      nbrs = {}
      
      each_class do |k|
        res = []
        
        get_data[k].each do |s|
          next if s == rs # exclude self
          
          d = diff_sample(rs, s, rk, k)
          res << [d, s]
        end
        
        nbrs[k] = (res.sort { |x, y| x[0] <=> y[0] }[0...@k]).collect { |z| z[1] }
      end
      
      nbrs
    end # find_k_nearest_nb
    
    
    # difference between two samples
    def diff_sample(s1, s2, k1, k2)
      d = 0.0
            
      each_feature do |f|
        d += diff_feature(f, s1, s2, k1, k2)**2
      end
      
      d
    end # diff_sample
    
    
    # difference beween the feature (f) of two samples
    def diff_feature(f, s1, s2, k1, k2)
      d = 0.0
      
      if s1.has_key?(f) and s2.has_key?(f) # no missing value
        d = (s1[f] == s2[f]) ? 0.0 : 1.0
      elsif not s1.has_key?(f) and not s2.has_key?(f) # two missing values
        fvs = get_feature_values(f).uniq
        fvs.each do |mv|
          d -= calc_p(f, mv, k1)*calc_p(f, mv, k2)
        end
        d += 1
      elsif not s1.has_key?(f) # s1: one missing value
        # diff(f, s1, s2) = 1 - P(value(f, s2)|class(s1))
        d = 1 - calc_p(f, s2[f], k1)
      else # s2: one missing value
        # diff(f, s1, s2) = 1 - P(value(f, s1)|class(s2))
        d = 1 - calc_p(f, s1[f], k2)
      end
      
      d
    end # diff_feature
    
    
    # calc probability of missing value (mv)
    def calc_p(f, mv, k) 
      # cache
      if not @f2mvp
        @f2mvp = {}
        
        each_feature do |f|
          @f2mvp[f] = {}
          
          each_class do |k|
            @f2mvp[f][k] = {}
            
            fvs = get_feature_values(f).uniq
            fvs.each do |v|
              n = 0.0
              
              get_data[k].each do |s|
                n += 1 if s.has_key?(f) and s[f] == v
              end
              
              @f2mvp[f][k][v] = n/get_data[k].size
            end
          end
        end
      end
      
      @f2mvp[f][k][mv]
    end
    
    
    # calc feature (f) contribution from neighbors
    def calc_score(f, rs, rk, nbrs)
      score = 0.0
      
      nbrs.each do |k, nbs|
        if k == rk # near hit
          nbs.each do |s|
            score -= (diff_feature(f, rs, s, rk, k)**2/nbs.size)
          end
        else # near_miss
          nbs.each do |s|
            score += (get_data[k].size/get_sample_size.to_f *
                     diff_feature(f, rs, s, rk, k)**2/nbs.size)
          end
        end
      end
      
      score
    end
    
    
  end # class
  
  
end # module