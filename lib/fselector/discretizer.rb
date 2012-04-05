#
# discretize continous feature
#
module Discretizer
  # include Entropy module
  #include Entropy
  
  # module variable, Chi-squared value vs p-value
  @@df_p2chisq = nil
  @@chi_squared_table = "\
   DegreeOfFreedom  0.995 0.975 0.75  0.5 0.25  0.2 0.1 0.05  0.025 0.02  0.01  0.005 0.002 0.001
   1 0.0000393 0.000982  0.1015  0.4549  1.3233  1.642 2.706 3.841 5.024 5.412 6.635 7.879 9.55  10.828
   2 0.01  0.0506  0.5754  1.3863  2.7726  3.219 4.605 5.991 7.378 7.824 9.21  10.597  12.429  13.816
   3 0.0717  0.216 1.2125  2.366 4.1083  4.642 6.251 7.815 9.348 9.837 11.345  12.838  14.796  16.266
   4 0.207 0.484 1.9226  3.3567  5.3853  5.989 7.779 9.488 11.143  11.668  13.277  14.86 16.924  18.467
   5 0.412 0.831 2.6746  4.3515  6.6257  7.289 9.236 11.07 12.833  13.388  15.086  16.75 18.907  20.515
   6 0.676 1.237 3.4546  5.3481  7.8408  8.558 10.645  12.592  14.449  15.033  16.812  18.548  20.791  22.458
   7 0.989 1.69  4.2549  6.3458  9.0371  9.803 12.017  14.067  16.013  16.622  18.475  20.278  22.601  24.322
   8 1.344 2.18  5.0706  7.3441  10.2189 11.03 13.362  15.507  17.535  18.168  20.09 21.955  24.352  26.124
   9 1.735 2.7 5.8988  8.3428  11.3887 12.242  14.684  16.919  19.023  19.679  21.666  23.589  26.056  27.877
   10  2.156 3.247 6.737 9.342 12.549  13.442  15.987  18.307  20.483  21.161  23.209  25.188  27.722  29.588
   11  2.603 3.816 7.584 10.341  13.701  14.631  17.275  19.675  21.92 22.618  24.725  26.757  29.354  31.264
   12  3.074 4.404 8.438 11.34 14.845  15.812  18.549  21.026  23.337  24.054  26.217  28.3  30.957  32.909
   13  3.565 5.009 9.299 12.34 15.984  16.985  19.812  22.362  24.736  25.472  27.688  29.819  32.535  34.528
   14  4.075 5.629 10.165  13.339  17.117  18.151  21.064  23.685  26.119  26.873  29.141  31.319  34.091  36.123
   15  4.601 6.262 11.037  14.339  18.245  19.311  22.307  24.996  27.488  28.259  30.578  32.801  35.628  37.697
   16  5.142 6.908 11.912  15.338  19.369  20.465  23.542  26.296  28.845  29.633  32  34.267  37.146  39.252
   17  5.697 7.564 12.792  16.338  20.489  21.615  24.769  27.587  30.191  30.995  33.409  35.718  38.648  40.79
   18  6.265 8.231 13.675  17.338  21.605  22.76 25.989  28.869  31.526  32.346  34.805  37.156  40.136  42.312
   19  6.844 8.907 14.562  18.338  22.718  23.9  27.204  30.144  32.852  33.687  36.191  38.582  41.61 43.82
   20  7.434 9.591 15.452  19.337  23.828  25.038  28.412  31.41 34.17 35.02 37.566  39.997  43.072  45.315
   21  8.034 10.283  16.344  20.337  24.935  26.171  29.615  32.671  35.479  36.343  38.932  41.401  44.522  46.797
   22  8.643 10.982  17.24 21.337  26.039  27.301  30.813  33.924  36.781  37.659  40.289  42.796  45.962  48.268
   23  9.26  11.689  18.137  22.337  27.141  28.429  32.007  35.172  38.076  38.968  41.638  44.181  47.391  49.728
   24  9.886 12.401  19.037  23.337  28.241  29.553  33.196  36.415  39.364  40.27 42.98 45.559  48.812  51.179
   25  10.52 13.12 19.939  24.337  29.339  30.675  34.382  37.652  40.646  41.566  44.314  46.928  50.223  52.62
   26  11.16 13.844  20.843  25.336  30.435  31.795  35.563  38.885  41.923  42.856  45.642  48.29 51.627  54.052
   27  11.808  14.573  21.749  26.336  31.528  32.912  36.741  40.113  43.195  44.14 46.963  49.645  53.023  55.476
   28  12.461  15.308  22.657  27.336  32.62 34.027  37.916  41.337  44.461  45.419  48.278  50.993  54.411  56.892
   29  13.121  16.047  23.567  28.336  33.711  35.139  39.087  42.557  45.722  46.693  49.588  52.336  55.792  58.301
   30  13.787  16.791  24.478  29.336  34.8  36.25 40.256  43.773  46.979  47.962  50.892  53.672  57.167  59.703"
    
  # discretize by equal-width intervals
  #
  # @param [Integer] n_interval
  #        desired number of intervals
  # @note data structure will be altered
  def discretize_by_equal_width!(n_interval)
    n_interval = 1 if n_interval < 1 # at least one interval
    
    # first determine min and max for each feature
    f2min_max = {}
    each_feature do |f|
      fvs = get_feature_values(f)
      f2min_max[f] = [fvs.min, fvs.max]
    end
    
    # then discretize
    each_sample do |k, s|
      s.keys.each do |f|
        min_v, max_v = f2min_max[f]
        if min_v == max_v
          wn = 0
        else
          wn = ((s[f]-min_v)*n_interval.to_f / (max_v-min_v)).to_i
        end
        
        s[f] = (wn<n_interval) ? wn : n_interval-1
      end
    end
    
  end # discretize_equal_width!
  
  
  # discretize by equal-frequency intervals
  #
  # @param [Integer] n_interval
  #        desired number of intervals
  # @note data structure will be altered
  def discretize_by_equal_frequency!(n_interval)
    n_interval = 1 if n_interval < 1 # at least one interval
    
    # first determine the boundaries
    f2bs = Hash.new { |h,k| h[k] = [] }
    each_feature do |f|
      fvs = get_feature_values(f).sort
      # number of samples in each interval
      ns = (fvs.size.to_f/n_interval).round
      fvs.each_with_index do |v, i|
        if (i+1)%ns == 0 and (i+1)<fvs.size
          f2bs[f] << (v+fvs[i+1])/2.0
        end
      end
      f2bs[f] << fvs.max+1.0 # add the rightmost boundary
    end
    
    # then discretize
    each_sample do |k, s|
      s.keys.each do |f|
        s[f] = get_index(s[f], f2bs[f])
      end
    end
    
  end # discretize_equal_frequency!
  
  
  #
  # discretize by ChiMerge algorithm
  #
  # @param [Float] alpha confidence level, 
  #   supported alpha values (up to 30 degree of freedom) are:  
  #   0.995, 0.975, 0.75, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.005, 0.002, 0.001
  # @note data structure will be altered
  #
  # ref: [ChiMerge: Discretization of Numberic Attributes](http://sci2s.ugr.es/keel/pdf/algorithm/congreso/1992-Kerber-ChimErge-AAAI92.pdf)
  #
  # chi-squared values and associated p values can be looked up at
  # [Wikipedia](http://en.wikipedia.org/wiki/Chi-squared_distribution)  
  # degrees of freedom: one less than the number of classes
  #    
  def discretize_by_ChiMerge!(alpha=0.10)
    df = get_classes.size-1
    abort "[#{__FILE__}@#{__LINE__}]: "+
          "only degree of freedom <= 30 is supported!" if df > 30
          
    if not [0.995, 0.975, 0.75, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.005, 0.002, 0.001].include? alpha
      abort "[#{__FILE__}@#{__LINE__}]: "+
          "only the following alpha values are supported: \n"+
          "0.995, 0.975, 0.75, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.005, 0.002, 0.001"
    end
    
    chisq = get_chi2_from_df_alpha(df, alpha)
    
    # for intialization
    hzero = {}
    each_class do |k|
      hzero[k] = 0.0
    end
    
    # determine the final boundaries for each feature
    f2bs = {}
    each_feature do |f|
      #f = "Sepal.Length"
      # 1a. initialize boundaries
      bs, cs, qs = [], [], []
      fvs = get_feature_values(f).sort.uniq
      fvs.each_with_index do |v, i|
        if i+1 < fvs.size
          bs << (v+fvs[i+1])/2.0
          cs << hzero.dup
          qs << 0.0
        end
      end
      bs << fvs.max+1.0 # add the rightmost boundary
      cs << hzero.dup
      
      # 1b. initialize counts for each interval
      each_sample do |k, s|
        next if not s.has_key? f
        bs.each_with_index do |b, i|
          if s[f] < b
            cs[i][k] += 1.0
            break
          end
        end
      end
      
      # 1c. initialize chi-squared values between two adjacent intervals
      cs.each_with_index do |c, i|
        if i+1 < cs.size
          qs[i] = calc_chisq(c, cs[i+1])
        end
      end
      
      # 2. iteratively merge intervals
      until qs.empty? or qs.min > chisq
        qs.each_with_index do |q, i|
          if q == qs.min
            #pp "i: #{i}"
            #pp bs.join(',')
            #pp qs.join(',')
            
            # update cs for merged two intervals
            cm = {}
            each_class do |k|
              cm[k] = cs[i][k]+cs[i+1][k]
            end
            
            # update qs if necessary
            # before merged intervals
            if i-1 >= 0
              qs[i-1] = calc_chisq(cs[i-1], cm)
            end
            # after merged intervals
            if i+1 < qs.size
              qs[i+1] = calc_chisq(cm, cs[i+2])
            end
            
            # merge
            bs = bs[0...i] + bs[i+1...bs.size]
            cs = cs[0...i] + [cm] + cs[i+2...cs.size]
            qs = qs[0...i] + qs[i+1...qs.size]
            
            #pp bs.join(',')
            #pp qs.join(',')
            
            # break out
            break
            
          end
        end
      end
      
      # 3. record the final boundaries
      f2bs[f] = bs
    end

    # discretize according to each feature's boundaries
    each_sample do |k, s|
      s.keys.each do |f|
        s[f] = get_index(s[f], f2bs[f])
      end
    end
    
  end # discretize_ChiMerge!
  
  
  #
  # discretize by Multi-Interval Discretization (MID) algorithm
  #
  # @note no missing feature values allowed and data structure will be altered
  # 
  # ref: [Multi-Interval Discretization of Continuous-Valued Attributes for Classification Learning](http://www.ijcai.org/Past%20Proceedings/IJCAI-93-VOL2/PDF/022.pdf)
  #
  def discretize_by_MID!
    # determine the final boundaries
    f2cp = {} # cut points for each feature
    each_feature do |f|
      cv = get_class_labels
      # we assume no missing feature values 
      fv = get_feature_values(f)
      
      n = cv.size
      # sort cv and fv according ascending order of fv
      sis = (0...n).to_a.sort { |i,j| fv[i] <=> fv[j] }
      cv = cv.values_at(*sis)
      fv = fv.values_at(*sis)
      
      # get initial boundaries
      bs = []
      fv.each_with_index do |v, i|
        # cut point (Ta) for feature A must always be a value between
        # two examples of different classes in the sequence of sorted examples
        # see orginal reference
        if i < n-1 and cv[i] != cv[i+1]
          bs << (v+fv[i+1])/2.0
        end
      end
      bs.uniq! # remove duplicates
      
      # main algorithm, iteratively determine cut point
      cp = []
      partition(cv, fv, bs, cp)
      
      # add the rightmost boundary for convenience
      cp << fv.max+1.0
      # record cut points for feature (f)
      f2cp[f] = cp      
    end
    
    # discretize based on cut points
    each_sample do |k, s|
      s.keys.each do |f|
        s[f] = get_index(s[f], f2cp[f])
      end
    end
    
  end # discretize_by_MID!
  
  private
  
  # read Chi-squared table
  def get_chi2_from_df_alpha(df, alpha)
    if not @@df_p2chisq
      @@df_p2chisq = {}
      
      ps = nil
      @@chi_squared_table.split(/\n/).each do |ln|
        head, *data = ln.strip.split
        
        if head == 'DegreeOfFreedom'
          ps = data.collect { |p| p.to_f }
        else
          degree = head.to_i
          @@df_p2chisq[degree] = {}
          ps.each_with_index do |p,i|
            @@df_p2chisq[degree][p] = data[i].to_f
          end
        end
      end
    end
    
    @@df_p2chisq[df][alpha]
  end
  
  
  # get index from sorted boundaries
  #
  # min -- | -- | -- | ... max |
  #        b1   b2   b3        bn(=max+1)
  #      1    2    3   ...   n
  #
  def get_index(v, boundaries)
    boundaries.each_with_index do |b, i|
      return i+1 if v < b
    end
  end # get_index
  

  # calc the chi squared value of ChiMerge
  def calc_chisq(cs1, cs2)
    r1 = cs1.values.sum
    r2 = cs2.values.sum
    n = r1+r2
    
    q = 0.0
    
    each_class do |k|
      ek1 = r1*(cs1[k]+cs2[k])/n
      ek2 = r2*(cs1[k]+cs2[k])/n
      
      q += (cs1[k]-ek1)**2/(ek1<0.5?0.5:ek1)+
      (cs2[k]-ek2)**2/(ek2<0.5?0.5:ek2)
    end
    
    q
  end # calc_chisq
  
  
  #
  # Multi-Interval Discretization main algorithm
  # recursively always selecting the best cut point
  #
  # @param [Array] cv class labels
  # @param [Array] fv feature values
  # @param [Array] bs potential cut points
  # @param [Array] cp resultant cut points
  def partition(cv, fv, bs, cp)
    # best cut point
    cp_best = nil
    
    # binary subset at the best cut point
    cv1_best, cv2_best = nil, nil
    fv1_best, fv2_best = nil, nil
    bs1_best, bs2_best = nil, nil
    
    # best information gain
    gain_best = -100.0
    ent_best = -100.0
    ent1_best = -100.0
    ent2_best = -100.0
    
    # try each potential cut point
    bs.each do |b|
      # binary split
      cv1_try, cv2_try, fv1_try, fv2_try, bs1_try, bs2_try = 
        binary_split(cv, fv, bs, b)
      
      # gain for this cut point
      ent_try = get_marginal_entropy(cv)
      ent1_try = get_marginal_entropy(cv1_try)
      ent2_try = get_marginal_entropy(cv2_try)
      gain_try = ent_try - 
                 (cv1_try.size.to_f/cv.size) * ent1_try - 
                 (cv2_try.size.to_f/cv.size) * ent2_try
      
      #pp gain_try
      if gain_try > gain_best
        cp_best = b
        cv1_best, cv2_best = cv1_try, cv2_try
        fv1_best, fv2_best = fv1_try, fv2_try
        bs1_best, bs2_best = bs1_try, bs2_try
        
        gain_best = gain_try
        ent_best = ent_try
        ent1_best, ent2_best = ent1_try, ent2_try
      end
    end
    
    # to cut or not to cut?
    #
    # Gain(A,T;S) > 1/N * log2(N-1) + 1/N * delta(A,T;S)
    if cp_best
      n = cv.size.to_f
      k = cv.uniq.size.to_f
      k1 = cv1_best.uniq.size.to_f
      k2 = cv2_best.uniq.size.to_f
      delta = Math.log2(3**k-2)-(k*ent_best - k1*ent1_best - k2*ent2_best)
      
      # accept cut point
      if gain_best > (Math.log2(n-1)/n + delta/n)
        # a: record cut point
        cp << cp_best
          
        # b: recursively call on subset
        partition(cv1_best, fv1_best, bs1_best, cp)
        partition(cv2_best, fv2_best, bs2_best, cp)
      end
    end
  end
  
  
  # binarily split based on a cut point
  def binary_split(cv, fv, bs, cut_point)
    cv1, cv2, fv1, fv2, bs1, bs2 = [], [], [], [], [], []
    fv.each_with_index do |v, i|
      if v < cut_point
        cv1 << cv[i]
        fv1 << v
      else
        cv2 << cv[i]
        fv2 << v
      end
    end
    
    bs.each do |b|
      if b < cut_point
        bs1 << b
      else
        bs2 << b
      end
    end
    
    # return subset
    [cv1, cv2, fv1, fv2, bs1, bs2]
  end
  
  
end # module
