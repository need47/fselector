#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Random (Rand), no pratical use but can be used as a baseline
#
#  Rand = rand numbers within [0..1)
#  
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class Random < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
    
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
  
  
end # module
