#
# discretilize continous feature
#
module Discretilizer
  # discretize by equal-width intervals
  #
  # @param [Integer] n_interval
  #        desired number of intervals
  # @note data structure will be altered
  def discretize_equal_width!(n_interval)
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
  def discretize_equal_frequency!(n_interval)
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
  # ref: [ChiMerge: Discretization of Numberic Attributes][url]
  # [url]: http://sci2s.ugr.es/keel/pdf/algorithm/congreso/1992-Kerber-ChimErge-AAAI92.pdf
  #
  # chi-squared values and associated p values can be looked up at
  # [Wikipedia](http://en.wikipedia.org/wiki/Chi-squared_distribution) <br>
  # degrees of freedom: one less than number of classes
  #
  #     chi-squared values vs p values
  #     degree_of_freedom  p<0.10  p<0.05  p<0.01  p<0.001
  #             1          2.71    3.84    6.64    10.83
  #             2          4.60    5.99    9.21    13.82
  #             3          6.35    7.82    11.34   16.27
  #    
  def discretize_chimerge!(chisq)
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
    
  end # discretize_chimerge!
  
  private
  
  # get index from sorted boundaries
  #
  # min -- | -- | -- | ... max |
  #        b0   b1   b2        bn(=max+1)
  #      0    1    2   ...   n
  #
  def get_index(v, boundaries)
    boundaries.each_with_index do |b, i|
      return i if v < b
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
  
  
end # module