#
# discretize continous feature
#
module Discretizer
  # include Entropy module
  include Entropy
  
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
  # @param [Float] chisq chi-squared value
  # @note data structure will be altered
  #
  # ref: [ChiMerge: Discretization of Numberic Attributes](http://sci2s.ugr.es/keel/pdf/algorithm/congreso/1992-Kerber-ChimErge-AAAI92.pdf)
  #
  # chi-squared values and associated p values can be looked up at
  # [Wikipedia](http://en.wikipedia.org/wiki/Chi-squared_distribution)  
  # degrees of freedom: one less than number of classes
  #
  #     chi-squared values vs p values
  #     degree_of_freedom  p<0.10  p<0.05  p<0.01  p<0.001
  #             1          2.71    3.84    6.64    10.83
  #             2          4.60    5.99    9.21    13.82
  #             3          6.35    7.82    11.34   16.27
  #    
  def discretize_by_ChiMerge!(chisq)
    # chisq = 4.60 # for iris::Sepal.Length
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
  # @note data structure will be altered
  #
  # ref: [Multi-Interval Discretization of Continuous-Valued Attributes for Classification Learning](http://www.ijcai.org/Past%20Proceedings/IJCAI-93-VOL2/PDF/022.pdf)
  #
  def discretize_by_MID!
    # determine the final boundaries
    f2cp = {} # cut points for each feature
    each_feature do |f|
      cv = get_class_labels
      # for now we assume no missing feature values 
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
      ck1 = 
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