#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Las Vegas Filter (LVF) for discrete feature, 
# use **select\_feature!** for feature selection
#
# @note we only keep one of the equivalently good solutions
#
# ref: [Review and Evaluation of Feature Selection Algorithms in Synthetic Problems](http://arxiv.org/abs/1101.2320)
#
  class LasVegasFilter < BaseDiscrete    
    #
    # initialize from existing data structure
    # 
    # @param [Integer] max_iter maximum number of iterations
    # @param [Hash] data existing data structure
    #
    def initialize(max_iter=100, data=nil)
      super(data)
      @max_iter = max_iter || 100
    end
    
    private
    
    # Las Vegas Filter (LVF) algorithm
    def get_feature_subset
      feats = get_features # initial best solution
      data = get_data # working dataset
      
      j0 = check_J(data, feats)
          
      subset = lvf(data, feats, j0)
      
      subset
    end #get_feature_subset
    
    
    # check evaluation mean J -> (0, 1]
    def check_J(data, feats)
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
        inconsis += cnts.sum-cnts.max
      end
      
      # inconsistency rate
      sz = dt.values.flatten.size # inconsis / num_of_sample
      ir = (sz.zero?) ? 0.0 : inconsis/sz
      
      1.0/(1.0 + ir)
    end
    
    
    # lvf
    def lvf(data, feats, j0)
      subset_best = feats
      sz_best = subset_best.size
      #pp [sz_best, j0]
      
      @max_iter.times do
        # always sample a smaller feature subset than sz_best at random
        f_try = feats.sample(rand(sz_best-1)+1)
        j = check_J(data, f_try)
        #pp [f_try.size, j]
        
        if j >= j0
          subset_best = f_try
          sz_best = f_try.size
          #pp [sz_best, j, 'best']
        end
      end
      
      subset_best
    end
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::LVF instead of FSelector::LasVegasFilter
  LVF = LasVegasFilter
  
  
end # module
