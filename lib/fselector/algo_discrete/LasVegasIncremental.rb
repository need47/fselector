#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Las Vegas Incremental (LVI) for discrete feature, 
# use **select\_feature!** for feature selection
#
# ref: [Incremental Feature Selection](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.34.8218)
#
  class LasVegasIncremental < BaseDiscrete
    # include Consistency module
    include Consistency
    
    #
    # initialize from an existing data structure
    # 
    # @param [Integer] max_iter maximum number of iterations
    # @param [Float] portion percentage of data used by LVF
    #
    def initialize(max_iter=100, portion=0.10, data=nil)
      super(data)
      @max_iter = max_iter || 100
      @portion = portion || 0.10
    end
    
    private    
    
    # Las Vegas Incremental (LVI) algorithm
    def get_feature_subset
      data = get_data # working dataset
      s0, s1 = portion(data)
      feats = get_features
      j0 = get_IR(data) # initial data inconsistency rate
      
      # instead of s0 and s1, we play with their inst_cnt Hash tables
      inst_cnt_s0 = get_instance_count(s0)
      inst_cnt_s1 = get_instance_count(s1)
      
      subset = feats # initial feature subset
      
      while true
        j_s0, f_try = lvf(inst_cnt_s0, feats, j0) # keep only one equivalently good subset
        #pp f_try
        #s = inst_cnt_s0.merge(inst_cnt_s1) { |kk, v1, v2| v1.merge(v2) {|vv,x1,x2| x1+x2 }  }
        #pp s==get_instance_count
        
        j_s1, inconC = check_incon_rate(inst_cnt_s1, f_try)
        
        #pp [j0, j_s0, j_s1, count(inst_cnt_s0), count(inst_cnt_s1), f_try.size]
        
        if j_s0+j_s1 <= j0 # or inconC.empty?
          subset = f_try
          break
        else
          update(inst_cnt_s0, inst_cnt_s1, inconC)
        end
      end
      
      #pp check_incon_rate(data, subset)[0]
      subset
    end #get_feature_subset
    
    
    def portion(data)
      s0, s1 = {}, {}
      data.each do |k, ss|
        sz = ss.size
        n0 = (sz * @portion).to_i
        
        indices = (0...sz).to_a
        n0_indices = indices.sample(n0)
        n1_indices = indices - n0_indices

        s0[k] = ss.values_at(*n0_indices)
        s1[k] = ss.values_at(*n1_indices)
      end
      
      [s0, s1]
    end
    
    # check evaluation mean J -> (0, 1]
    def check_incon_rate(inst_cnt, feats)
      #pp feats
      ir, inconC = 0.0, []
      
      # build new inst_count for feats
      inst_cnt_new = {}
      k2k = {} # map of key_old to key_new

      inst_cnt.each do |key, hcnt|
        key_new = feats.sort.collect { |f|
          match_data = key.match(/#{f}:.*?\|/)
          match_data[0] if match_data
        }.compact.join # remove nil entry and join
        next if key_new.empty?
        
        k2k[key] = key_new
        
        hcnt_new = inst_cnt_new[key_new] || Hash.new(0)
        # merge cnts
        inst_cnt_new[key_new] = hcnt_new.merge(hcnt) { |kk, v1, v2| v1+v2 }
      end

      ir = get_IR_by_count(inst_cnt_new)
      
      # check inconsistency instances
      inst_cnt.keys.each do |key|
        next if not k2k.has_key? key
        
        key_new = k2k[key]
        
        cnt_new = inst_cnt_new[key_new].values
        if cnt_new.sum-cnt_new.max > 0 # inconsistency
          inconC << key
        end
      end
      
      [ir, inconC]
    end
    
    
    # lvf
    def lvf(inst_cnt, feats, j0)
      subset_best = feats
      sz_best = subset_best.size
      j_best = j0
      
      @max_iter.times do
        # always sample a smaller feature subset than sz_best at random
        f_try = feats.sample(rand(sz_best-1)+1)
        j_try = get_IR_by_feature(inst_cnt, f_try)
        
        if j_try <= j0
          subset_best = f_try
          sz_best = subset_best.size
          j_best = j_try
        end
      end
      
      [j_best, subset_best]
    end # lvf
    
    
    # update inst_cnt_s0, inst_cnt_s1
    def update(inst_cnt_s0, inst_cnt_s1, inconC)      
      inconC.each do |inst_key|
        hcnt_s0 = inst_cnt_s0[inst_key] ||= Hash.new(0)
        hcnt_s1 = inst_cnt_s1[inst_key]
        
        inst_cnt_s0[inst_key] = hcnt_s0.merge(hcnt_s1) { |kk, v1, v2| v1+v2 }
        # remove from inst_cnt_s0
        inst_cnt_s1.delete(inst_key)
      end
    end # update
    
    
    # the number of instances
    def count(inst_cnt)
      inst_cnt.values.collect { |hcnt| hcnt.values.sum }.sum
    end # count
    
        
  end # class
  
  
  # shortcut so that you can use FSelector::LVI instead of FSelector::LasVegasIncremental
  LVI = LasVegasIncremental
  
  
end # module
