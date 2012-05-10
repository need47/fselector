#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# INTERACT algorithm, 
# use **select\_feature!** for feature selection
#
# ref: [Searching for Interacting Features](http://www.public.asu.edu/~huanliu/papers/ijcai07.pdf)
#
  class INTERACT < BaseDiscrete
    # include Entropy module
    include Entropy
    # include Consistency module
    include Consistency
    
    # this algo selects a subset of feature
    @algo_type = :feature_subset_selection
    
    #
    # initialize from an existing data structure
    # 
    # @param [Float] delta predefined inconsistency rate threshold for a feature
    #
    def initialize(delta=0.0001, data=nil)
      super(data)
      @delta = delta || 0.0001
    end
    
    private
    
    # INTERACT algorithm
    def get_feature_subset     
      subset, f2su = get_features.dup, {}
      
      # part 1, get symmetrical uncertainty for each feature
      cv = get_class_labels
      each_feature do |f|
        fv = get_feature_values(f, :include_missing_values)
        su = get_symmetrical_uncertainty(fv, cv)
        f2su[f] = su
      end
      
      # sort slist based on ascending order of the su of a feature
      subset = subset.sort { |x,y| f2su[x] <=> f2su[y] }
      
      # part 2, initialize instance count Hash table
      inst_cnt = get_instance_count
      #pp inst_cnt
      
      # cache inconsistency rate of the current list
      ir_now = get_IR_by_count(inst_cnt)
      
      # part 3, feature selection based on c-contribution
      f_try = get_next_element(subset, nil)
      
      while f_try
        f_try_next = get_next_element(subset, f_try)
        ir_try, inst_cnt_try = get_c_contribution(f_try, inst_cnt)
        
        #pp [f_try, ir_try, ir_now, ir_try-ir_now, inst_cnt.size, inst_cnt_try.size, subset.size]
        
        if ir_try-ir_now <= @delta
          subset.delete(f_try)
          ir_now = ir_try
          inst_cnt = inst_cnt_try
        end
        
        f_try = f_try_next
      end
      
      #pp inst_cnt
      subset
    end #get_feature_subset
      
    
    # get next element for current one
    def get_next_element(slist, curr=nil)
      if curr == nil
        return slist.first # will return nil if slist is empty
      end
      
      idx = slist.index(curr)
      if not idx or idx == slist.size-1 # no curr or curr is the last entry
        return nil
      else
        return slist[idx+1]
      end
    end # get_next_element   
    
    
    
    # get c-contribution (Hash-table)
    def get_c_contribution(f_try, inst_cnt)
      # make a new inst_cnt by removing f_try
      # note the key of inst_cnt looks like: f1:v1|f2:v2|f3:v3
      inst_cnt_try = {}
      
      inst_cnt.each do |key, hcnt|
        key_try = key.gsub(/#{f_try}:.*?\|/, '')
        hcnt_try = inst_cnt_try[key_try] || Hash.new(0)
        # merge cnt
        inst_cnt_try[key_try] = hcnt_try.merge(hcnt) {|kk, v1, v2| v1+v2 }
      end
      
      ir_try = get_IR_by_count(inst_cnt_try)
      
      [ir_try, inst_cnt_try]
    end # get c-contribution
    
    
  end # class
  
  
end # module
