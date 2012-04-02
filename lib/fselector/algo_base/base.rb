#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
  #
  # base ranking algorithm
  #
  class Base
    # include FileIO
    include FileIO
    
    # initialize from an existing data structure
    def initialize(data=nil)
      @data = data
      @opts = {} # store non-data information
    end
    
    
    #
    # iterator for each class
    #
    #     e.g.
    #     self.each_class do |k|
    #       puts k
    #     end
    #
    def each_class
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "block must be given!"
      else
        get_classes.each { |k| yield k }
      end
    end
    
    
    #
    # iterator for each feature
    #
    #     e.g.
    #     self.each_feature do |f|
    #       puts f
    #     end
    #
    def each_feature
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "block must be given!"
      else
        get_features.each { |f| yield f }
      end
    end
    
    
    #
    # iterator for each sample with class label
    #
    #     e.g.
    #     self.each_sample do |k, s|
    #       print k
    #       s.each { |f, v| ' '+v }
    #       puts
    #     end
    #
    def each_sample
      if not block_given?
        abort "[#{__FILE__}@#{__LINE__}]: "+
              " block must be given!"
      else      
        get_data.each do |k, samples|
          samples.each { |s| yield k, s }
        end
      end
    end
    
    
    # get classes
    def get_classes
      @classes ||= @data.keys
    end
    
    
    # set classes
    def set_classes(classes)
      if classes and classes.class == Array
        @classes = classes
      else
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "classes must be a Array object!"
      end
    end

    
    # get unique features
    def get_features
      @features ||= @data.map { |x| x[1].map { |y| y.keys } }.flatten.uniq
    end
    
    
    #
    # get feature values
    #
    # @param [Symbol] f feature of interest
    # @param [Symbol] ck class of interest.
    #   if not nil return feature values for the
    #   specific class, otherwise return all feature values
    #
    def get_feature_values(f, ck=nil)
      @fvs ||= {}
      
      if not @fvs.has_key? f
        @fvs[f] = {}
        each_sample do |k, s|
          @fvs[f][k] = [] if not @fvs[f].has_key? k
          @fvs[f][k] << s[f] if s.has_key? f
        end
      end
      
      ck ? @fvs[f][ck] : @fvs[f].values.flatten   
    end
    
    
    # set features
    def set_features(features)
      if features and features.class == Array
        @features = features
      else
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "features must be a Array object!"
      end
    end
    
    
    # get data
    def get_data
      @data
    end
    
    
    # set data
    def set_data(data)
      if data and data.class == Hash
        @data = data
        # clear
        @classes, @features, @fvs = nil, nil, nil
        @scores, @ranks, @sz = nil, nil, nil
      else
        abort "[#{__FILE__}@#{__LINE__}]: "+
              "data must be a Hash object!"
      end
      data
    end
    
    
    # get non-data information
    def get_opt(key)
      @opts.has_key?(key) ? @opts[key] : nil
    end
    
    
    # set non-data information as a key-value pair
    def set_opt(key, value)
      @opts[key] = value
    end
    
    
    # number of samples
    def get_sample_size
      @sz ||= get_data.values.flatten.size
    end
       
    #
    # get scores of all features for all classes
    #
    # @return [Hash] \{ feature => 
    #                \{ class_1 => score_1, class_2 => score_2, :BEST => score_best } }
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
      
      scores = get_feature_scores
      
      # get the ranked features
      @ranks = {} # feature => rank
      
      # the larger, the better
      sorted_features = scores.keys.sort do |x,y|
        scores[y][:BEST] <=> scores[x][:BEST]
      end
      
      sorted_features.each_with_index do |sf, si|
        @ranks[sf] = si+1
      end
      
      @ranks
    end
    
    
    #
    # reconstruct data with selected features
    #
    # @return [Hash] data after feature selection
    # @note derived class must implement its own get_subset()
    #
    def select_feature!
      subset = get_feature_subset
      return if subset.empty?
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = {}
        
        s.each do |f, v|
          my_s[f] = v if subset.include? f
        end
        
        my_data[k] << my_s if not my_s.empty?
      end
      
      set_data(my_data)
    end
    
    
    #
    # reconstruct data with feature scores satisfying cutoff
    #
    # @param [String] criterion 
    #   valid criterion can be '>0.5', '>= 0.4', '==2', '<=1' or '<0.2'
    # @param [Hash] my_scores
    #   user customized feature scores
    # @return [Hash] data after feature selection
    # @note data structure will be altered
    #
    def select_feature_by_score!(criterion, my_scores=nil)
      # user scores or internal scores
      scores = my_scores || get_feature_scores
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = {}
        
        s.each do |f, v|
          my_s[f] = v if eval("#{scores[f][:BEST]} #{criterion}")
        end
        
        my_data[k] << my_s if not my_s.empty?
      end
          
      set_data(my_data)
    end
        
    
    #
    # reconstruct data by rank
    #
    # @param [String] criterion 
    #   valid criterion can be '>11', '>= 10', '==1', '<=10' or '<20'
    # @param [Hash] my_ranks
    #   user customized feature ranks
    # @return [Hash] data after feature selection
    # @note data structure will be altered
    #
    def select_feature_by_rank!(criterion, my_ranks=nil)
      # user ranks or internal ranks
      ranks = my_ranks || get_feature_ranks
      
      my_data = {}
      
      each_sample do |k, s|
        my_data[k] ||= []
        my_s = {}
        
        s.each do |f,v|
          my_s[f] = v if eval("#{ranks[f]} #{criterion}")
        end
        
        my_data[k] << my_s if not my_s.empty?
      end
      
      set_data(my_data)
    end
    
    private
    
    # set feature (f) score (s) for class (k)
    def set_feature_score(f, k, s)
      @scores ||= {}
      @scores[f] ||= {}
      @scores[f][k] = s
    end
    
    # get subset of feature
    def get_feature_subset
      abort "[#{__FILE__}@#{__LINE__}]: "+
              "derived class must implement its own get_feature_subset()"
    end
  
  
  end # class


end # module
