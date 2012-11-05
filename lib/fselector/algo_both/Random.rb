#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Random (Rand) for discrete, continuous or mixed feature, 
# no pratical use but can be used for test purpose
#
#  Rand assignes random score of [0..1) to each feature
#  
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class Random < Base
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    #
    # initialize from an existing data structure
    #
    # @param [Integer] seed seed form random number
    #   generator. provided for reproducible results, 
    #   otherwise use current time as seed
    #
    def initialize(seed=nil, data=nil)
      super(data)
      
      srand(seed) if seed
    end
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        set_feature_score(f, k, rand)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::Rand instead of FSelector::Random
  Rand = Random
  
  
end # module
