#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  #
  # base class for a single feature selection algorithm
  #
  class Base
    # include FileIO
    include FileIO
    # include ReplaceMissingValues
    include ReplaceMissingValues
    
    class << self
      # class-level instance variable, type of feature selection algorithm.
      #
      # derived class (except Base*** class) must set its own type with one 
      # of the following two:  
      # - :feature\_weighting         # when algo outputs weight for each feature  
      # - :feature\_subset_selection  # when algo outputs a subset of features
      attr_accessor :algo_type
    end
    
    # get the type of feature selection algorithm at class-level
    def algo_type
      self.class.algo_type
    end
    
    
    # initialize from an existing data structure
    def initialize(data=nil)
      @data = data # store data
      @opts = {} # store non-data information
    end
    
    
    #
    # iterator for each class, a block must be given. e.g. 
    #
    #     self.each_class do |k|
    #       puts k
    #     end
    #
    def each_class
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  block must be given!"
      else
        get_classes.each { |k| yield k }
      end
    end
    
    
    #
    # iterator for each feature, a block must be given. e.g.
    #
    #     self.each_feature do |f|
    #       puts f
    #     end
    #
    def each_feature
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  block must be given!"
      else
        get_features.each { |f| yield f }
      end
    end
    
    
    #
    # iterator for each sample with class label, 
    # a block must be given. e.g. 
    #
    #     self.each_sample do |k, s|
    #       print k
    #       s.each { |f, v| print " #{v}" }
    #       puts
    #     end
    #
    def each_sample
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              " block must be given!"
      else      
        get_data.each do |k, samples|
          samples.each { |s| yield k, s }
        end
      end
    end
    
    
    #
    # get (unique) classes labels
    #
    # @return [Array<Symbol>] unique class labels
    #
    def get_classes
      @classes ||= @data.keys
    end
    
    
    #
    # get class labels for all samples
    #
    # @return [Array<Symbol>] class labels for all classes, 
    #   same size as the number of samples
    #
    def get_class_labels
      if not @cv
        @cv = []
        
        each_sample do |k, s|
          @cv << k
        end
      end
      
      @cv
    end
    
    
    #
    # set classes
    #
    # @param [Array<Symbol>] classes source unique class labels
    #
    def set_classes(classes)
      if classes and classes.class == Array
        @classes = classes
      else
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  classes must be a Array object!"
      end
    end

    #
    # get (unique) features
    #
    # @return [Array<Symbol>] unique features
    #
    def get_features
      @features ||= @data.map { |x| x[1].map { |y| y.keys } }.flatten.uniq
    end
    
    
    #
    # get feature values
    #
    # @param [Symbol] f feature of interest
    # @param [Symbol] mv including missing feature values?
    #   don't include missing feature values (recorded as nils)
    #   if nil, include otherwise
    # @param [Symbol] ck class of interest.
    #   return feature values for all classes, otherwise return feature
    #   values for the specific class (ck)
    # @return [Hash] feature values
    #
    def get_feature_values(f, mv=nil, ck=nil)
      @fvs ||= {}
      
      if not @fvs.has_key? f
        @fvs[f] = {}
        
        each_sample do |k, s|
          @fvs[f][k] = [] if not @fvs[f].has_key? k
          if s.has_key? f
            @fvs[f][k] << s[f]
          else
            @fvs[f][k] << nil # for missing featue values
          end
        end
      end
      
      if mv # include missing feature values
        return ck ? @fvs[f][ck] : @fvs[f].values.flatten
      else # don't include
        return ck ? @fvs[f][ck].compact : @fvs[f].values.flatten.compact
      end  
    end
    
    
    #
    # set features
    #
    # @param [Array<Symbol>] features source unique features
    #
    def set_features(features)
      if features and features.class == Array
        @features = features
      else
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  features must be a Array object!"
      end
    end
    
    
    #
    # get internal data
    #
    # @return [Hash] internal data
    #
    def get_data
      @data
    end
    
    
    #
    # get a copy of internal data, by means of the standard Marshal library
    #
    # @return [Hash] a copy of internal data
    #
    def get_data_copy
      Marshal.load(Marshal.dump(@data)) if @data
    end
    
    
    #
    # set data and clean relevant variables in case of data change
    #
    # @param [Hash] data source data structure
    #
    def set_data(data)
      if data and data.class == Hash
        # clear variables
        clear_vars if @data
        @data = data # set new data structure
      else
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  data must be a Hash object!"
      end
    end
    
    
    # get non-data information for a given key
    def get_opt(key)
      @opts.has_key?(key) ? @opts[key] : nil
    end
    
    
    # set non-data information as a key-value pair
    def set_opt(key, value)
      @opts[key] = value
    end
    
    
    #
    # number of samples
    #
    # @return [Integer] sample size
    #
    def get_sample_size
      @sz ||= get_data.values.flatten.size
    end
    
    
    #
    # get scores of all features for all classes
    #
    # @return [Hash] \{ feature => 
    #                \{ class\_1 => score\_1, class\_2 => score\_2, :BEST => score\_best } }
    #
    def get_feature_scores
      return @scores if @scores # already done
      
      each_feature do |f|
        calc_contribution(f)
      end
      
      # best score for feature
      @scores.each do |f, ks|
        # the larger, the better
        @scores[f][:BEST] = ks.values.max
      end
      #@scores.each { |x,v| puts "#{x} => #{v[:BEST]}" }
      
      @scores
    end
    
    
    #
    # get the ranked features based on their best scores
    #
    # @return [Hash] feature ranks
    #
    def get_feature_ranks
      return @ranks if @ranks # already done
      
      # make feature ranks from feature scores
      set_ranks_from_scores
      
      @ranks
    end
    
    
    #
    # reconstruct data with selected features
    #
    # @note data structure will be altered. Derived class must 
    #   implement its own get\_feature_subset(). This is only available for 
    #   the subset selection type of algorithms, see {file:README.md}
    #
    def select_feature!
      if not self.algo_type == :feature_subset_selection
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  select_feature! is the interface for the type of feature subset selection algorithms only. \n" +
              "  please consider select_featue_by_score! or select_feature_by_rank!, \n" +
              "  which is the interface for the type of feature weighting algorithms"
      end
      
      # derived class must implement its own one
      subset = get_feature_subset
      return if subset.empty?
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = s.select { |f, v| subset.include? f }        
        my_data[k] << my_s if not my_s.empty?
      end
      
      set_data(my_data)
    end
    
    
    #
    # reconstruct data by feature score satisfying criterion
    #
    # @param [String] criterion 
    #   valid criterion can be '>0.5', '>=0.4', '==2.0', '<=1.0' or '<0.2'
    # @param [Hash] my_scores
    #   user customized feature scores
    # @note data structure will be altered. This is only available for 
    #   the weighting type of algorithms, see {file:README.md}
    #
    def select_feature_by_score!(criterion, my_scores=nil)
      if not self.algo_type == :feature_weighting
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  select_feature_by_score! is the interface for the type of feature weighting algorithms only. \n" +
              "  please consider select_featue!, \n" +
              "  which is the interface for the type of feature subset selection algorithms"
      end
      
      # user scores or internal scores
      scores = my_scores || get_feature_scores
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = s.select { |f, v| eval("#{scores[f][:BEST]} #{criterion}") }       
        my_data[k] << my_s if not my_s.empty?
      end
          
      set_data(my_data)
    end
        
    
    #
    # reconstruct data by feature rank satisfying criterion
    #
    # @param [String] criterion 
    #   valid criterion can be '>11', '>=10', '==1', '<=10' or '<20'
    # @param [Hash] my_ranks
    #   user customized feature ranks
    # @note data structure will be altered. This is only available for 
    #   the weighting type of algorithms, see {file:README.md}
    #
    def select_feature_by_rank!(criterion, my_ranks=nil)
      if not self.algo_type == :feature_weighting
        abort "[#{__FILE__}@#{__LINE__}]: \n"+
              "  select_feature_by_rank! is the interface for the type of feature weighting algorithms only. \n" +
              "  please consider select_featue!, \n" +
              "  which is the interface for the type of feature subset selection algorithms"
      end
      
      # user ranks or internal ranks
      ranks = my_ranks || get_feature_ranks
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = s.select { |f, v| eval("#{ranks[f]} #{criterion}") }        
        my_data[k] << my_s if not my_s.empty?
      end
      
      set_data(my_data)
    end
    
    private
    
    #
    # clear variables when data structure is altered, this is 
    # useful when data structure has changed while 
    # you still want to use the same instance
    #
    # @note the variables of original data structure (@data) and 
    #   algorithm type (@algo_type) are retained
    #
    def clear_vars
      @classes, @features, @fvs = nil, nil, nil
      @scores, @ranks, @sz = nil, nil, nil
      @cv, @fvs, @opts = nil, nil, {}
    end
    
    
    # set feature (f) score (s) for class (k)
    def set_feature_score(f, k, s)
      @scores ||= {}
      @scores[f] ||= {}
      @scores[f][k] = s
    end
    
    
    #
    # set feature ranks from feature scores
    #
    # @param [Hash] scores feature scores
    # @return [Hash] feature scores
    # @note  the larger the score, the smaller (better) its rank
    #
    def set_ranks_from_scores
      # get feature scores
      scores = get_feature_scores
      
      # get the ranked features
      @ranks = {} # feature => rank
      
      # the larger the score, the smaller (better) its rank
      sorted_features = scores.keys.sort do |x,y|
        scores[y][:BEST] <=> scores[x][:BEST] # use :BEST feature score
      end
      
      sorted_features.each_with_index do |sf, si|
        @ranks[sf] = si+1
      end
      
      @ranks
    end
    
    
    # get feature subset, for the type of subset selection algorithms
    def get_feature_subset
      abort "[#{__FILE__}@#{__LINE__}]: \n"+
            "  derived subclass must implement its own get_feature_subset()"
    end
  
  
  end # class


end # module
