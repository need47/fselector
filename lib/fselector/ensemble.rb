#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  #
  # feature selection by an ensemble of feature selectors
  #
  # for the type of feature weighting algorithms, call one of the following two 
  # functions first before calling select\_feature\_by\_score! or  
  # select\_feature\_by\_rank! for feature selection:  
  # - ensemble\_by\_score()  # ensemble scores are based on that of individual selector  
  # - ensemble\_by\_rank()   # ensemble ranks are based on that of individual selector
  #
  # for the type of feature subset selection algorithms, use
  # select\_feature! for feature selection (based on feature frequency count)
  #
  # @note ensemble feature selectors share the same feature selection 
  #   interface as single feature selector
  #
  class BaseEnsemble < Base
    #
    # initialize from an existing data structure
    #
    def initialize(data=nil)
      super(data)
    end
    
    
    # override algo\_type for BaseEnsemble
    #
    # get the type of ensemble feature selectors at instance-level
    def algo_type
      @algo_type # instance-level variable
    end
    
    
    #
    # override get\_feature\_scores() for BaseEnsemble
    #
    def get_feature_scores
      return @scores if @scores
      
      abort "[#{__FILE__}@#{__LINE__}]: \n"+
            "  please call one ensemble method first!"
    end
    
    
    #
    # override get\_feature\_ranks() for BaseEnsemble
    #
    def get_feature_ranks
      return @ranks if @ranks
      
      if @scores # calc ranks based on scores
        set_ranks_from_scores
        return @ranks
      else
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  please call one ensemble method first!"
      end
    end
    
    
    #
    # ensemble scores are made from that of individual feature selector
    #
    # @param [Symbol] ensem_method how the ensemble score should 
    #   be derived from those of individual feature selector  
    #   allowed values are:  
    #   - :by\_min  # use min score  
    #   - :by\_max  # use max score  
    #   - :by\_ave  # use ave score  
    #   - :by\_sum  # use sum score
    # @param [Symbol] norm_method score normalization method  
    #   - :none          # use score as is  
    #   - :by\_min\_max  # score scaled to [0, 1]  
    #   - :by\_zscore    # score converted to zscore
    #
    # @note scores from different feature selectors are often incompatible 
    #   with each other, so we need to normalize them first
    #
    def ensemble_by_score(ensem_method=:by_max, norm_method=:by_zscore)
      if not [:by_min, :by_max, :by_ave, :by_sum].include? ensem_method
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  only :by_min, :by_max and :by_ave are supported ensemble methods!"
      end
      
      if not [:none, :by_min_max, :by_zscore].include? norm_method
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  only :none, :by_min_max and :by_zscore are supported normalization methods!"
      end
      
      # get score from each feature selector in the ensemble
      ensem_scores = get_ensemble_scores
      
      # normalization (if needed)
      self.send(norm_method, ensem_scores) if not norm_method == :none
      
      scores = {}
      
      each_feature do |f|
        scores[f] = {}
        # feature score from individual feature selector
        score_arr = ensem_scores.collect { |es| es[f][:BEST] }
        # ensemble score
        scores[f][:BEST] = self.send(ensem_method, score_arr)
      end
      
      #pp scores
      @scores = scores
    end
    
    
    #
    # ensemble ranks are made from that of individual feature selector
    #
    # @param [Symbol] ensem_method how the ensemble rank should 
    #   be derived from those of individual feature selector  
    #   allowed values are:  
    #   - :by\_min  # use min rank  
    #   - :by\_max  # use max rank  
    #   - :by\_ave  # use ave rank  
    #   - :by\_sum  # use sum rank
    #
    def ensemble_by_rank(ensem_method=:by_sum)
      if not [:by_min, :by_max, :by_ave, :by_sum].include? ensem_method
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  only :by_min, :by_max and :by_ave are supported ensemble methods!"
      end
      
      # get ranks from individual feature selector in ensemble
      ensem_ranks = get_ensemble_ranks
      
      ranks = {}
      
      each_feature do |f|
        # feature rank from individual feature selector
        rank_arr = ensem_ranks.collect { |er| er[f] }
        # ensemble rank
        ranks[f] = self.send(ensem_method, rank_arr)
      end
      #pp ranks
      new_ranks = {}
      
      sorted_features = ranks.keys.sort do |x, y|
        ranks[x] <=> ranks[y]
      end
      sorted_features.each_with_index do |sf, si|
        new_ranks[sf] = si+1
      end
      
      @ranks = new_ranks
    end
    
    private    
    
    # by average value of an array
    def by_ave(arr)
      arr.ave if arr.class == Array
    end
    
    
    # by min value of an array
    def by_min(arr)
      arr.min if arr.class == Array
    end
    
    
    # by max value of an array
    def by_max(arr)
      arr.max if arr.class == Array
    end
    
    
    # by sum of an array
    def by_sum(arr)
      arr.sum if arr.class == Array
    end
    
    
    #
    # normalize feature scores
    # by scaling to [0, 1]
    #
    # @note original scores will be altered in place
    #
    def by_min_max(scores)
      scores.each do |score| # score from each feature selector
        score_best = score.collect { |f, ks| ks[:BEST] }
        min, max = score_best.min, score_best.max
        
        score.each do |f, ks|
          ks[:BEST] = (ks[:BEST]-min) / (max-min)
        end
      end
    end
    
    
    #
    # normalize feature scores
    # by z-score
    #
    # @note original scores will be altered in place
    #
    def by_zscore(scores)
      scores.each do |score| # score from each feature selector
        score_best = score.collect { |f, ks| ks[:BEST] }
        ave, sd = score_best.ave, score_best.sd
        
        score.each do |f, ks|
          ks[:BEST] = (ks[:BEST]-ave) / sd
        end
      end
    end
    
    
  end # BaseEnsemble
  
  
  #
  # feature selection by an ensemble of feature selectors 
  # that created by using a single feature selection algorithm
  #
  # for the type of feature weighting algorithms, call one of the following two 
  # functions first before calling select\_feature\_by\_score! or 
  # select\_feature\_by\_rank! for feature selection:  
  # - ensemble\_by\_score()  # ensemble scores are based on that of individual selector  
  # - ensemble\_by\_rank()   # ensemble ranks are based on that of individual selector
  #
  # for the type of feature subset selection algorithms, use
  # select\_feature! for feature selection (based on feature frequency count)
  #
  # @note ensemble feature selectors share the same feature selection 
  #   interface as single feature selector
  #
  class EnsembleSingle < BaseEnsemble
    #
    # initialize from a single feature selection algorithm
    #
    # @param [Algorithm] algo feature selection algorithm
    # @param [Integer] nselector number of feature selectors
    # @param [Float] pdata percentage of data used by each feature selector
    # @param [Symbol] sampling_method sampling method  
    #   - :bootstrap\_sampling  # random sampling with replacement   
    #   - :random\_sampling     # random sampling without replacement
    #
    # ref: [Robust Feature Selection Using Ensemble Feature Selection Techniques](http://dl.acm.org/citation.cfm?id=1432021)
    #
    def initialize(algo, nselector=40, pdata=0.90, sampling_method=:bootstrap_sampling, data=nil)
      super(data)
      
      @algo = algo
      @nselector = nselector || 40
      @pdata = pdata || 0.90
      @sampling_method = sampling_method || :bootstrap_sampling
      
      # set feature selector type
      @algo_type = algo.algo_type
    end
    
    
    #
    # get ensemble feature scores
    #
    # @return [Array] feature scores from all feature selectors
    #
    def get_ensemble_scores
      ensem_scores = []
      
      @nselector.times do
        # sampling
        my_data = self.send(@sampling_method)
        
        # score from this feature selector
        r = @algo
        r.set_data(my_data)
        ensem_scores << r.get_feature_scores
      end
      
      ensem_scores
      #pp ensem_scores
    end # get_feature_scores
    
    
    #
    # get ensemble feature ranks
    #
    # @return [Array] feature ranks from all feature selectors
    #
    def get_ensemble_ranks
      ensem_ranks = []
      
      @nselector.times do
        # sampling
        my_data = self.send(@sampling_method)
        
        # rank from this feature selector
        r = @algo
        r.set_data(my_data)
        ensem_ranks << r.get_feature_ranks
      end
      
      ensem_ranks
      #pp ensem_ranks
    end # get_ensemble_ranks
    
    private
    
    #
    # override get\_feature\_subset() for EnsembleSingle, 
    # select a subset of features based on frequency count
    #
    # @note only the features that occur in the ensemble 
    # with above average count are selected
    #
    def get_feature_subset
      f2count = Hash.new(0)
      total_count = 0.0
      
      @nselector.times do
        # sampling
        my_data = self.send(@sampling_method)
        
        # subset from this selector
        r = @algo
        r.set_data(my_data)
        # note we call a private method here
        r_subset = r.send(:get_feature_subset)
        
        # record count
        r_subset.each do |f|
          total_count += 1
          f2count[f] += 1
        end
      end
      #pp f2count
      #pp total_count
      
      # only the features that occur in the ensemble 
      # with above average count are selected
      subset = f2count.keys.select { |f| f2count[f] > total_count/f2count.keys.size }
      
      subset
    end # get_feature_subset
    
    # sampling with replacement
    # @note sampling will be done stratifily in each class
    def bootstrap_sampling
      my_data = {}
      
      each_class do |k|
        my_data[k] = []
        
        n = (get_data[k].size * @pdata).to_i
        n.times { # with replacement
          my_data[k] << get_data[k].sample
        }
      end
      
      my_data
    end # bootstrap_sampling
    
    
    # sampling without replacement
    # @note sampling will be done stratifily in each class
    def random_sampling
      my_data = {}
      
      each_class do |k|        
        n = (get_data[k].size * @pdata).to_i
        my_data[k] = get_data[k].sample(n) # without replacement
      end
      
      my_data
    end # random_sampling
    
  end # EnsembleSingle
  
  
  #
  # feature selection by an ensemble of feature selectors 
  # that created by using multiple algorithms of the same type
  #
  # for the type of feature weighting algorithms, call one of the following two 
  # functions first before calling select\_feature\_by\_score! or 
  # select\_feature\_by\_rank! for feature selection:  
  # - ensemble\_by\_score()  # ensemble scores are based on that of individual selector  
  # - ensemble\_by\_rank()   # ensemble ranks are based on that of individual selector
  #
  # for the type of feature subset selection algorithms, use
  # select\_feature! for feature selection (based on feature frequency count)
  #
  # @note ensemble feature selectors share the same feature selection 
  #   interface as single feature selector
  #
  class EnsembleMultiple < BaseEnsemble
    #
    # initialize from multiple algorithms
    #
    # @param [Array] algos multiple feature selection algorithms
    # @note different algorithms must be of the same type, 
    #   either weighting or subset selection (see {file:README.md}) 
    #
    def initialize(*algos)
      super(nil)
      
      @algos = []
      algos.each do |r|
        @algos << r
      end
      
      @algo_type = algos.first.algo_type
      # all algorithms must be of the same type
      algos.each do |r|
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  all algorithms must be of the same type" if not r.algo_type == @algo_type
      end
    end
    
    #
    # get ensemble feature scores
    #
    # @return [Array] feature scores from all algorithms
    #
    def get_ensemble_scores
      ensem_scores = []
      
      @algos.each do |r|
        # score from this feature selector
        r.set_data(get_data) # share same data structure
        ensem_scores << r.get_feature_scores
      end
      
      ensem_scores
      #pp ensem_scores
    end # get_feature_scores
    
    
    #
    # get ensemble feature ranks
    #
    # @return [Array] feature ranks from all feature selectors
    #
    def get_ensemble_ranks
      ensem_ranks = []
      
      @algos.each do |r|
        # rank from this feature selector
        r.set_data(get_data)
        ensem_ranks << r.get_feature_ranks
      end
      
      ensem_ranks
      #pp ensem_ranks
    end # get_ensemble_ranks
    
    
    private
    
    #
    # override get\_feature\_subset() for EnsembleMultiple, 
    # select a subset of features based on frequency count
    #
    # @note only the features that occur in the ensemble 
    # with above average count are selected
    #
    def get_feature_subset
      f2count = Hash.new(0)
      total_count = 0.0
      
      @algos.each do |r|
        # subset from this selector
        r.set_data(get_data)
        # note we call a private method here
        r_subset = r.send(:get_feature_subset)
        
        # record count
        r_subset.each do |f|
          total_count += 1
          f2count[f] += 1
        end
      end
      #pp f2count
      #pp total_count
      
      # only the features that occur in the ensemble 
      # with above average count are selected
      subset = f2count.keys.select { |f| f2count[f] > total_count/f2count.keys.size }
      
      subset
    end # get_feature_subset
    
    
  end # EnsembleMultiple
  
  
end # module
