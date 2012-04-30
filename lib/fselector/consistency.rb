#
# data consistency-related functions
#
module Consistency
  #
  # get the counts of each (unique) instance (without class label)  
  # for each class, the resulting Hash table, as suggested by Zheng Zhao 
  # and Huan Liu, looks like:
  #
  #     {
  #      'f1:v1|f2:v2|...|fn:vn|' => {k1=>c1, k2=>c2, ..., kn=>cn},
  #       ...
  #     }
  #     
  #     where we use the (sorted) features and their values to construct 
  #     the key for Hash table, i.e., v_i is the value for feature f_i. 
  #     Note the symbol : separates a feature and its value, and the 
  #     symbol | separates a feature-value pair. In other words, they 
  #     should not appear in any feature or its value. If so, please 
  #     replace them with other symbols in advance. The c_i is the 
  #     instance count for class k_i 
  #
  # @param [Hash] my_data data of interest, use internal data by default
  # @return [Hash] counts of each (unique) instance for each class
  # @note intended for mulitple calculations, because chekcing data inconsistency 
  #   rate based on the resultant Hash table is very efficient and avoids 
  #   reconstructing new data structure and repetitive counting. For instead, 
  #   you only rebuild the Hash keys and merge relevant counts
  #
  # ref: [Searching for Interacting Features](http://www.public.asu.edu/~huanliu/papers/ijcai07.pdf)
  #
  def get_instance_count(my_data=nil)
    my_data ||= get_data # use internal data by default
    inst_cnt = {}
    
    my_data.each do |k, ss|
      ss.each do |s|
        # sort make sure a same key
        # : separates a feature and its value
        # | separates a feature-value pair
        key = s.keys.sort.collect { |f| "#{f}:#{s[f]}|"}.join
        inst_cnt[key] ||= Hash.new(0)
        inst_cnt[key][k] += 1 # for key in class k
      end
    end
    
    inst_cnt
  end # get_instance_count
  
  
  #
  # get data inconsistency rate based on the instance count in Hash table
  #
  # @param [Hash] inst_cnt the counts of each (unique) instance (without 
  #   class label) for each class
  # @return [Float] data inconsistency rate
  #
  def get_IR_by_count(inst_cnt)    
    incon, sample_size = 0.0, 0.0
    
    inst_cnt.values.each do |hcnt|
      cnt = hcnt.values
      incon += cnt.sum-cnt.max
      sample_size += cnt.sum
    end
    
    # inconsistency rate
    (sample_size.zero?) ? 0.0 : incon/sample_size
  end # get_IR_by_count
  
  
  #
  # get data inconsistency rate for given features
  #
  # @param [Hash] inst_cnt source Hash table of instance count
  # @param [Array] feats consider only these features
  # @return [Float] data inconsistency rate
  #
  def get_IR_by_feature(inst_cnt, feats)
    return 0.0 if feats.empty?
    
    # build new inst_count for feats
    inst_cnt_new = {}
    
    inst_cnt.each do |key, hcnt|
      key_new = feats.sort.collect { |f|
        match_data = key.match(/#{f}:.*?\|/)
        match_data[0] if match_data
      }.compact.join # remove nil entry and join
      next if key_new.empty?
      
      hcnt_new = inst_cnt_new[key_new] || Hash.new(0)
      # merge cnts
      inst_cnt_new[key_new] = hcnt_new.merge(hcnt) { |kk, v1, v2| v1+v2 }
    end
    
    # inconsistency rate
    get_IR_by_count(inst_cnt_new)
  end # get_IR_by_feature
  
  
  #
  # get data inconsistency rate, suitable for single-time calculation
  #
  # @param [Hash] my_data data of interest, use internal data by default
  # @return [Float] data inconsistency rate
  #
  def get_IR(my_data=nil)
    my_data ||= get_data # use internal data by default
    inst_cnt = get_instance_count(my_data)
    ir = get_IR_by_count(inst_cnt)
    
    # inconsistency rate
    ir
  end # get_IR
  
  
end # module
