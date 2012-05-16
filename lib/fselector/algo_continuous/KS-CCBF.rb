#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Kolmogorov-Smirnov Class Correlation-Based Filter (KS-CCBF) for continuous feature
#
# ref: [Feature Selection for Supervised Classiﬁcation: A KolmogorovSmirnov Class Correlation-Based Filter](http://kzi.polsl.pl/~jbiesiada/Infosel/downolad/publikacje/09-Gliwice.pdf)
#
  class KS_CCBF < BaseContinuous
    # include Entropy module
    include Entropy
    
    # this algo outputs a subset of feature
    @algo_type = :feature_subset_selection
        
    #
    # initialize from an existing data structure
    # 
    # @param [Float] lamda threshold value [0, 1] to determin feature redundancy
    #
    def initialize(lamda=0.2, data=nil)
      super(data)
      
      @lamda = lamda || 0.2
    end
    
    private
    
    # INTERACT algorithm
    def get_feature_subset
      # make a copy of data, since the discretization method will alter internal data
      data_bak = get_data_copy
      
      # stage 1: calculate SUC coefficient
      # but let's discretize features first
      discretize_for_suc
      
      # then SUC
      f2suc = {}
      cv = get_class_labels
      each_feature do |f|
        fv = get_feature_values(f, :include_missing_values)
        f2suc[f] = get_symmetrical_uncertainty(fv, cv)
      end
      
      # sort feature according to descending order of its SUC
      subset = f2suc.keys.sort { |x, y| f2suc[y] <=> f2suc[x] }
      
      # restore data, note set_data also clear old variables
      set_data(data_bak)
      
      # stage 2: remove redundancy
      fp = subset.first
      while fp
        fq = get_next_element(subset, fp)
        
        while fq
          ks = calc_ks(fp, fq)
          
          if ks < @lamda
            fq_new = get_next_element(subset, fq)
            subset.delete(fq) # remove fq
            fq = fq_new
          else
            fq = get_next_element(subset, fq)
          end
        end
        
        fp = get_next_element(subset, fp)
      end
      
      subset      
    end # get_feature_subset
    
    
    # discretize continuous feature for calculating the SUC, 
    # which requires discrete features. See Discretizer module 
    # for available discretization methods. If you want to use 
    # alternative one, simply override this function
    def discretize_for_suc
      discretize_by_ChiMerge!(0.10)
    end
    
    
    # get the next element of fp
    def get_next_element(subset, fp)
      fq = nil
      
      idx = subset.index(fp)      
      if idx and idx < subset.size-1
        fq = subset[idx+1]
      end
      
      fq
    end # get_next_element
    
    
    # calculate K-S statistic (relying on R package) among all classes
    def calc_ks(fp, fq)
      ks = 0.0
      
      each_class do |k|
        R.sp = get_feature_values(fp, nil, k)
        R.sq = get_feature_values(fq, nil, k)
        
        # K-S test
        R.eval "ks <- ks.test(sp, sq)$statistic"
        
        # pull K-S statistic
        ks_try = R.ks
        
        # record max ks among classes
        ks = ks_try if ks_try > ks
      end
      
      ks
    end # calc_ks
    
    
  end # class
  
  
end # module
