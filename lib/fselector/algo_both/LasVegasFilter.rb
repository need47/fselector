#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Las Vegas Filter (LVF) for discrete, continuous or mixed feature, 
# use **select\_feature!** for feature selection
#
# @note we only keep one of the equivalently good solutions
#
# ref: [Review and Evaluation of Feature Selection Algorithms in Synthetic Problems](http://arxiv.org/abs/1101.2320)
#
  class LasVegasFilter < Base
    # include module
    include Consistency
    
    # this algo outputs a subset of feature
    @algo_type = :filter_by_feature_searching
    
    #
    # initialize from an existing data structure
    # 
    # @param [Integer] max_iter maximum number of iterations
    #
    def initialize(max_iter=100, data=nil)
      super(data)
      
      @max_iter = max_iter || 100
    end
    
    private
    
    # Las Vegas Filter (LVF) algorithm
    def get_feature_subset  
      inst_cnt = get_instance_count      
      j0 = get_IR_by_count(inst_cnt)
      
      feats = get_features
      subset = lvf(inst_cnt, feats, j0)
      
      subset
    end #get_feature_subset
    
    
    #
    # lvf, inst_count is used for calculating data inconsistency rate
    #
    def lvf(inst_count, feats, j0)
      subset_best = feats
      sz_best = subset_best.size
      #pp [sz_best, j0]
      
      @max_iter.times do
        # always sample a smaller feature subset than sz_best at random
        f_try = feats.sample(rand(sz_best-1)+1)
        j = get_IR_by_feature(inst_count, f_try)
        #pp [f_try.size, j, j0]
        
        if j <= j0
          subset_best = f_try
          sz_best = subset_best.size
          #pp [sz_best, j, 'best']
        end
      end
      
      subset_best
    end
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::LVF instead of FSelector::LasVegasFilter
  LVF = LasVegasFilter
  
  
end # module
