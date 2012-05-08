#
# replace missing feature values
#
module ReplaceMissingValues
  #
  # replace missing feature value by a fixed value, 
  # applicable to both discrete and continuous feature
  #
  # @note data structure will be altered
  #
  def replace_by_fixed_value!(val)
    each_sample do |k, s|
      each_feature do |f|
        if not s.has_key? f
          s[f] = val
        end
      end
    end
    
    # clear variables
    clear_vars
  end # replace_by_fixed_value
  
  
  #
  # replace missing feature value by mean feature value, 
  # applicable only to continuous feature
  #
  # @note data structure will be altered
  #
  def replace_by_mean_value!
    each_sample do |k, s|
      each_feature do |f|
        fv = get_feature_values(f)
        next if fv.size == get_sample_size # no missing values
        
        mean = fv.ave
        if not s.has_key? f
          s[f] = mean
        end
      end
    end
    
    # clear variables
    clear_vars
  end # replace_by_mean_value!
  
  
  #
  # replace missing feature value by median feature value, 
  # applicable only to continuous feature
  #
  # @note data structure will be altered
  #
  def replace_by_median_value!
    each_sample do |k, s|
      each_feature do |f|
        fv = get_feature_values(f)
        next if fv.size == get_sample_size # no missing values
        
        median = fv.median
        if not s.has_key? f
          s[f] = median
        end
      end
    end
    
    # clear variables
    clear_vars
  end # replace_by_median_value!
  
  
  #
  # replace missing feature value by most seen feature value, 
  # applicable only to discrete feature
  #
  # @note data structure will be altered
  #
  def replace_by_most_seen_value!
    each_sample do |k, s|
      each_feature do |f|
        fv = get_feature_values(f)
        next if fv.size == get_sample_size # no missing values
        
        seen_count, seen_value = 0, nil
        fv.uniq.each do |v|
          count = fv.count(v)
          if count > seen_count
            seen_count = count
            seen_value = v
          end
        end
        
        if not s.has_key? f
          s[f] = seen_value
        end
      end
    end
    
    # clear variables
    clear_vars
  end # replace_by_mean_value!
  
  
  #
  # replace missing feature value by weighted k-nearest neighbors' value, 
  # applicable to continuous feature for any k, but to discrete feature for k==1 only
  #
  #     distance-weighted contribution (w_i), normalized to 1
  #     
  #     w_i = (sum_d - d_i) / ((K-1) * sum_d)
  #     sum_d = sigma_i (d_i)
  #     K: number of d_i
  #     sigma_i(w_i) = 1
  #
  # @param [Integer] k number of nearest neighbors
  # @note data structure will be altered, and nearest neighbor 
  #   is determined by Euclidean distance
  #
  def replace_by_knn_value!(k=1)
    each_sample do |ki, si|
      # potential features having missing value
      mv_fs = get_features - si.keys
      next if mv_fs.empty? # sample si has no missing value
      
      # record object value for each feature missing value
      f2val = {}
      mv_fs.each do |mv_f|
        knn_s, knn_d = [], []
        
        each_sample do |kj, sj|
          # sample sj also has missing value of mv_f
          next if not sj.has_key? mv_f
          
          d = euclidean_distance(si, sj)
          idx = knn_d.index { |di| d<di }
          
          if idx
            knn_s.insert(idx, sj)
            knn_d.insert(idx, d)
            
            if knn_s.size > k
              knn_s = knn_s[0...k]
              knn_d = knn_d[0...k]
            end
          else
            if knn_s.size < k
              knn_s << sj
              knn_d << d
            end
          end
        end
        
        # distance-weighted value from knn
        knn_d_sum = knn_d.sum
        sz = knn_d.size
        val = 0.0
        knn_s.each_with_index do |s, i|
          if sz > 1
            if not knn_d_sum.zero?
              val += s[mv_f] * (knn_d_sum-knn_d[i]) / ((sz-1)*knn_d_sum)
            else
              val += s[mv_f] * 1.0 / sz
            end
          else # only one nearest neighbor
            val = s[mv_f]
          end
        end
        
        f2val[mv_f] = val
        pp [si, mv_f, knn_s, knn_d, val]
      end
      
      # set value
      f2val.each do |f, v|
        si[f] = v
      end
    end
    
    # clear variables
    clear_vars
  end # replace_by_knn_value!
  
  private
  
  # Euclidean distance of two samples
  #
  # @note features with missing value are ignored
  def euclidean_distance(s1, s2)
    d2 = 0.0
    get_features.each do |f|
      if s1.has_key? f and s2.has_key? f
        d2 += (s1[f]-s2[f])**2
      end
    end
    
    Math.sqrt(d2)
  end # euclidean_distance
  
  
end # ReplaceMissingValues
