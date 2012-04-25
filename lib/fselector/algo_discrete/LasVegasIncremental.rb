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
    #
    # initialize from existing data structure
    # 
    # @param [Integer] max_iter maximum number of iterations
    # @param [Float] portion percentage of data used by LVF
    # @param [Hash] data existing data structure
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
      feats = get_features # initial best solution
      j0 = check_incon_rate(data, feats)[0] # initial data inconsistency rate
      
      subset = feats # initial feature subset
      
      while true
        f_try = lvf(s0, feats, j0) # keep only one equivalently good subset
        #pp f_try
        
        j_s0 = check_incon_rate(s0, f_try)[0]
        j_s1, inconC = check_incon_rate(s1, f_try)
        
        #pp [j0, j_s0, j_s1, s0.values.flatten.size, s1.values.flatten.size, f_try.size]
        
        if j_s0+j_s1 <= j0 or inconC.empty?
          subset = f_try
          break
        else
          update(s0, s1, inconC)
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
    def check_incon_rate(data, feats)
      #pp feats
      ir, inconC = 0.0, []
      
      # create a reduced dataset within feats
      dt = {}
      data.each do |k, ss|
        dt[k] ||= []
        ss.each do |s|
          my_s = s.select { |f,v| feats.include? f }
          dt[k] << my_s if not my_s.empty?
        end
      end
      
      # check data inconsistency rate
      # get unique instances (except class label)
      inst_u = dt.values.flatten.uniq
      inst_u_cnt = {} # occurrences for each unique instance in each class
      ks = dt.keys
      
      # count
      inst_u.each_with_index do |inst, idx|
        inst_u_cnt[idx] = [] # record for all classes
        ks.each do |k|
          inst_u_cnt[idx] << dt[k].count(inst)
        end
      end
     
      # inconsistency count
      inconsis = 0.0
      inst_u_cnt.each do |idx, cnts|
        diff = cnts.sum-cnts.max
        inconsis += diff
        
        if not diff.zero? # inconsistent instance
          inconC << inst_u[idx]
        end
      end
      
      # inconsistency rate
      sz = dt.values.flatten.size # inconsis / num_of_sample
      ir = inconsis/sz if not sz.zero?
      
      [ir, inconC]
    end
    
    
    # lvf
    def lvf(data, feats, j0)
      subset_best = feats
      sz_best = subset_best.size
      
      @max_iter.times do
        # always sample a smaller feature subset than sz_best at random
        f_try = feats.sample(rand(sz_best-1)+1)
        
        if check_incon_rate(data, f_try)[0] <= j0
          subset_best = f_try
          sz_best = f_try.size
        end
      end
      
      subset_best
    end
    
    
    # update s0, s1
    def update(s0, s1, inconC)      
      inconC.each do |inst|
        s1.each do |k, sams|
          sams.each_with_index do |sam, i|
            if is_subset?(inst, sam)
              s0[k] << sam
              sams[i] = nil
            end
          end
          
          sams.compact!
        end
      end
    end
    
    
    # is Hash a is a subset of Hash b
    def is_subset?(ha, hb)
      ha.each do |k, v|
        if hb.has_key? k and v == hb[k]
          next
        else
          return false
        end
      end
      
      return true
    end
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::LVI instead of FSelector::LasVegasIncremental
  LVI = LasVegasIncremental
  
  
end # module
