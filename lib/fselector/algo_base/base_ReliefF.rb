#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# base class for extended Relief algorithm (ReliefF), see specialized versions for
# discrete feature (ReliefF\_d) and continuous feature (ReliefF\_c), respectively
#
# @note applicable to multi-class problem with missing data
#
# ref: [Estimating Attributes: Analysis and Extensions of RELIEF](http://www.springerlink.com/content/fp23jh2h0426ww45/)
#
  class BaseReliefF < Base      
    #
    # intialize from an existing data structure
    #
    # @param [Integer] m number of samples to be used 
    #   for estimating feature contribution. max can be
    #   the number of training samples
    # @param [Integer] k number of k-nearest neighbors
    #
    def initialize(m=30, k=10, data=nil)
      super(data)
      @m = m || 30 # default 30
      @k = k || 10 # default 10
    end
    
    private
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)      
      score = 0.0
      
      ## use all samples if @m not provided
      #@m = get_sample_size if not @m
      
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
          next if s.object_id == rs.object_id # exclude self
          
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
      abort "[#{__FILE__}@#{__LINE__}]: \n"+
            "  derived ReliefF algo must implement its own diff_feature()"
    end # diff_feature
    
    
    # calc probability of missing value (mv)
    def calc_p(f, mv, k) 
      # cache
      if not @f2mvp
        @f2mvp = {}
        
        each_feature do |_f|
          @f2mvp[_f] = {}
          
          each_class do |_k|
            @f2mvp[_f][_k] = {}
            
            fvs = get_feature_values(_f).uniq
            fvs.each do |v|
              n = 0.0
              
              get_data[_k].each do |s|
                n += 1 if s.has_key?(_f) and s[_f] == v
              end
              
              @f2mvp[_f][_k][v] = n/get_data[_k].size
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
    
    
    # overload clear\_vars for BaseReliefF
    def clear_vars
      super
      
      @f2mvp = nil
    end # clear_vars
    
    
  end # class
  
  
end # module