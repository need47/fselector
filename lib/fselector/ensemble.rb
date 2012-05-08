#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  #
  # feature selection by an ensemble of algorithms, 
  # sharing the same interface as single algo
  #
  # for the type of weighting algorithms,  you must call one of 
  # the following two functions before calling select\_feature\_by\_score! or 
  # select\_feature\_by\_rank! for feature selection:  
  # - ensemble\_by\_score()  if ensemble scores are based on those of individual algos  
  # - ensemble\_by\_rank()   if ensemble ranks are based on those of individual algos
  #
  # for the type of subset selection algorithm, use
  # select\_feature! for feature selection (based on consensus features)
  #
  class Ensemble < Base
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
    end
    
    
    #
    # reload set\_data() for Ensemble
    #
    # @param [Hash] data source data structure
    # @note all algos share the same data structure
    #
    def set_data(data)
      super
      
      @algos.each do |r|
        r.set_data(data)
      end
    end
    
    
    #
    # reload get\_feature\_scores() for Ensemble
    #
    def get_feature_scores
      return @scores if @scores
      
      abort "[#{__FILE__}@#{__LINE__}]: "+
              "please call one consensus scoring method first!"
    end
    
    
    #
    # reload get\_feature\_ranks() for Ensemble
    #
    def get_feature_ranks
      return @ranks if @ranks
      
      if @scores # calc ranks based on scores
        set_ranks_from_scores
        return @ranks
      else
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "please call one consensus ranking method first!"
      end
    end
    
    
    #
    # ensemble scores are made from those of individual algorithms
    #
    # @param [Symbol] ensem_method how the ensemble score should 
    #   be derived from those of individual algorithms  
    #   allowed values are:  
    #   - :by\_min # use min score  
    #   - :by\_max # use max score  
    #   - :by\_ave # use ave score
    # @param [Symbol] norm_method score normalization method 
    #   :by\_min\_max, score scaled to [0, 1]  
    #   :by\_zscore, score converted to zscore
    #
    # @note scores from different algos are usually incompatible with
    #   each other, so we need to normalize it first
    #
    def ensemble_by_score(ensem_method=:by_max, norm_method=:by_zscore)
      if not [:by_min, :by_max, :by_ave].include? ensem_method
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "only :by_min, :by_max and :by_ave are supported ensemble methods!"
      end
      
      if not [:by_min_max, :by_zscore].include? norm_method
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "only :by_min_max and :by_zscore are supported normalization methods!"
      end
      
      # normalization
      @algos.each do |r|
        self.send(norm_method, r)
      end
      
      @scores = {}
      
      each_feature do |f|
        @scores[f] = {}
        # score from individual algo
        score_arr = @algos.collect { |r| r.get_feature_scores[f][:BEST] }
        # ensemble score
        @scores[f][:BEST] = self.send(ensem_method, score_arr)
      end
    end
    
    
    #
    # ensemble ranks are made from those of individual algorithms
    #
    # @param [Symbol] ensem_method how the ensemble rank should 
    #   be derived from those of individual algorithms  
    #   allowed values are:  
    #   - :by\_min # use min rank  
    #   - :by\_max # use max rank  
    #   - :by\_ave # use ave rank
    #
    def ensemble_by_rank(ensem_method=:by_min)
      if not [:by_min, :by_max, :by_ave].include? ensem_method
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "only :by_min, :by_max and :by_ave are supported ensemble methods!"
      end
      
      ranks = {}
           
      each_feature do |f|
        # score from individual algo
        rank_arr = @algos.collect { |r| r.get_feature_ranks[f] }
        # ensemble rank
        ranks[f] = self.send(ensem_method, rank_arr)
      end
      
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
    
    #
    # reload get\_feature\_subset() for Ensemble
    #
    # select a subset of consensus features selected by multiple algos
    #
    # @note the subset of features are based on the consensus features 
    #   selected by multiple algos. This is suitable only for the type 
    #   of subset selection algorithms
    #
    def get_feature_subset
      subset = get_features.dup
      
      @algos.each do |r|
        # note we call a private method here
        r_subset = r.send(:get_feature_subset)
        subset = subset & r_subset
      end
      
      subset
    end
    
    
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
    
    #
    # normalize feature scores of each individual alogrithm (r)
    # by scaling to [0, 1]
    #
    # @note original scores will be altered in place
    #
    def by_min_max(r)
      scores = r.get_feature_scores
      scores_best = scores.collect { |f, ks|  ks[:BEST] }
      min, max = scores_best.min, scores_best.max
      
      scores.each do |f, ks|
        ks[:BEST] = (ks[:BEST]-min) / (max-min)
      end
    end
    
    
    #
    # normalize feature scores of each individual alogrithm (r)
    # by z-score
    #
    # @note original scores will be altered in place
    #
    def by_zscore(r)
      scores = r.get_feature_scores
      scores_best = scores.collect { |f, ks|  ks[:BEST] }
      ave, sd = scores_best.ave, scores_best.sd
      
      scores.each do |f, ks|
        ks[:BEST] = (ks[:BEST]-ave) / sd
      end
    end
    
    
  end # class
  
  
end # module
