#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# base class for Relief algorithm, see specialized versions for discrete
# feature (Relief\_d) and continuous feature (Relief\_c), respectively
#
# @note Relief applicable only to two-class problem without missing data
#
# ref: [The Feature Selection Problem: Traditional Methods and a New Algorithm](http://www.aaai.org/Papers/AAAI/1992/AAAI92-020.pdf)
#
  class BaseRelief < Base
    #
    # intialize from an existing data structure
    #
    # @param [Integer] m number of samples to be used 
    #   for estimating feature contribution. max can be
    #   the number of training samples
    #
    def initialize(m=30, data=nil)
      super(data)
      @m = m || 30 # default 30
    end
    
    private
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      if not get_classes.size == 2
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  Relief applicable only to two-class problems without missing data"
      end
      
      ## use all samples if @m not provided
      #@m = get_sample_size if not @m
      
      k1, k2 = get_classes
      score = 0.0
      
      @m.times do        
        # pick a sample at random
        rs, rk = pick_a_sample_at_random
        
        # find the nearest neighbor for each class
        nbrs = find_nearest_nb(rs, rk)
        
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
    
    
    # find nearest neighbor sample for given sample (rs) within class (k)
    def find_nearest_nb(rs, rk)
      nbrs = {}
      
      each_class do |k|
        nb, dmin = nil, 999
        get_data[k].each do |s|
          next if s.object_id == rs.object_id # exclude self
          
          d = diff_sample(rs, s)
          
          if d < dmin
            dmin = d
            nb = s
          end
        end
        
        nbrs[k] = nb
      end
      
      nbrs
    end # find_nearest_nb
    
    
    # difference between two samples
    def diff_sample(s1, s2)
      d = 0.0
      
      each_feature do |f|
        d += diff_feature(f, s1, s2)**2
      end
      
      d
    end # diff_sample
    
    
    # difference beween the feature (f) of two samples
    def diff_feature(f, s1, s2)
      abort "[#{__FILE__}@#{__LINE__}]: \n"+
            "  derived Relief algo must implement its own diff_feature()"
    end # diff_feature
    
    
    # calc feature (f) contribution from neighbors
    def calc_score(f, rs, rk, nbrs)
      score = 0.0
      
      nbrs.each do |k, s|
        if k == rk # near hit
          score -= diff_feature(f, rs, s)**2
        else # near_miss
          score += diff_feature(f, rs, s)**2
        end
      end
      
      score
    end # calc_score
    
    
  end # class
  
  
end # module
