#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# RandomSubset (RandS) for discrete, continuous or mixed feature, 
# no pratical use but can be used for test purpose
#
#  RandS generates a random subset of the original one
#
  class RandomSubset < Base
    # this algo outputs a subset of feature
    @algo_type = :filter_by_feature_searching
    
    #
    # initialize from an existing data structure
    #
    # @param [Integer] nfeature number of feature required 
    #   use random number if nil 
    #
    def initialize(nfeature=nil, data=nil)
      super(data)
      
      @nfeature = nfeature
    end
    
    private
    
    # RandomSubset algorithm
    def get_feature_subset
      subset = []
      
      if @nfeature and @nfeature > 0
        subset = get_features.sample(@nfeature)
      else
        n = rand(get_features.size)
        n += 1 if n == 0
        subset = get_features.sample(n)
      end
      
      subset
    end # get_feature_subset
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::RandS instead of FSelector::RandomSubset
  RandS = RandomSubset
  
  
end # module
