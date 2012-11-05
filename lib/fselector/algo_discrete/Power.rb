#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Power
#
#     Power = (1-fpr)^k - (1-tpr)^k
#     
#           = (1-B/(B+D))^k - (1-A/(A+C))^k
#     
#           = (D/(B+D))^k - (C/(A+C))^k
#
# ref: [An extensive empirical study of feature selection metrics for text classification](http://dl.acm.org/citation.cfm?id=944974)
#
  class Power < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    #
    # initialize from an existing data structure
    # 
    # @param [Integer] k power
    #
    def initialize(k=5, data=nil)
      super(data)
      
      @k = k || 5
    end
    
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        s = 0.0
        x, y = b+d, a+c
        
        s = (d/x)**(@k) - (c/y)**(@k) if not x.zero? and not y.zero?
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
end # module
