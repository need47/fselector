#
# replace missing feature values
#
module ReplaceMissingValues
  #
  # replace missing feature value with a fixed value
  # applicable for both discrete and continuous feature
  # @note data structure will be altered
  #
  def replace_with_fixed_value!(val)
    each_sample do |k, s|
      each_feature do |f|
        if not s.has_key? f
          s[f] = my_value
        end
      end
    end
    
    # clear variables
    clear_vars
  end # replace_fixed_value
  
  
  #
  # replace missing feature value with mean feature value
  # applicable only to continuous feature
  # @note data structure will be altered
  #
  def replace_with_mean_value!
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
  end # replace_with_mean_value!
  
  
  #
  # replace missing feature value with most seen feature value
  # applicable only to discrete feature
  # @note data structure will be altered
  #
  def replace_with_most_seen_value!
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
  end # replace_with_mean_value!
  
  
end # ReplaceMissingValues
