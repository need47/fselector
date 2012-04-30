#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  # select feature by an ensemble of ranking algorithms
  class Ensemble < Base
    #
    # initialize from multiple algorithms
    #
    # @param [Array] algos multiple feature selection algorithms
    #
    def initialize(*algos)
      super(nil)
      
      @algos = []
      algos.each do |r|
        @algos << r
      end
    end
    
    
    #
    # reload set\_data
    #
    # @note all algos share the same data structure
    #
    def set_data(data)
      super
      
      @algos.each do |r|
        r.set_data(data)
      end
    end
    
    
    #
    # reload get\_feature\_scores
    #
    def get_feature_scores
      return @scores if @scores
      
      abort "[#{__FILE__}@#{__LINE__}]: "+
              "please call one consensus scoring method first!"
    end
    
    
    #
    # reload get\_feature\_ranks
    #
    def get_feature_ranks
      return @ranks if @ranks
      
      abort "[#{__FILE__}@#{__LINE__}]: "+
              "please call one consensus ranking method first!"
    end
    
    
    # ensemble based on score
    #
    # @param [Method] by_what by what criterion that ensemble
    #   score should be obtained from those of individual algorithms  
    #   allowed values are:  
    #   - method(:by\_min) # by min score  
    #   - method(:by\_max) # by max score  
    #   - method(:by\_ave) # by ave score
    # @param [Integer] norm normalization  
    #   :min\_max, score scaled to [0, 1]  
    #   :zscore, score converted to zscore
    #
    # @note scores from different algos are usually incompatible with
    #   each other, we have to normalize it first
    #
    def ensemble_by_score(by_what=method(:by_max), norm=:min_max)
      @algos.each do |r|
        if norm == :min_max
          normalize_min_max!(r)
        elsif norm == :zscore
          normalize_zscore!(r)
        else
          abort "[#{__FILE__}@#{__LINE__}]: "+
              "invalid normalizer, only :min_max and :zscore supported!"
        end
      end
      
      @scores = {}
      
      each_feature do |f|
        @scores[f] = {}
        @scores[f][:BEST] = by_what.call(
          @algos.collect { |r| r.get_feature_scores[f][:BEST] }
        )
      end      
    end
    
    
    # ensemble based on rank
    #
    # @param [Method] by_what by what criterion that ensemble
    #   rank should be obtained from those of individual algorithms  
    #   allowed values are:  
    #   - method(:by\_min) # by min rank  
    #   - method(:by\_max) # by max rank  
    #   - method(:by\_ave) # by ave rank
    #
    def ensemble_by_rank(by_what=method(:by_min))
      ranks = {}
           
      each_feature do |f|
        ranks[f] = by_what.call(
          @algos.collect { |r| r.get_feature_ranks[f] }
        )
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
    
    private
    
    #
    # normalize feature scores of each individual alogrithm (r)
    # by scaling to [0, 1]
    #
    # @note original scores will be altered in place
    #
    def normalize_min_max!(r)
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
    def normalize_zscore!(r)
      scores = r.get_feature_scores
      scores_best = scores.collect { |f, ks|  ks[:BEST] }
      ave, sd = scores_best.ave, scores_best.sd
      
      scores.each do |f, ks|
        ks[:BEST] = (ks[:BEST]-ave) / sd
      end
    end
    
    
  end # class
  
  
end # module
