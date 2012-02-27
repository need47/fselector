#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Bi-Normal Separation (BNS)
#
#     BNS = |F'(tpr) - F'(fpr)|
#      
#     where F' is normal inverse cumulative distribution function
#     R executable is required to calculate qnorm, i.e. F'(x)
# 
# ref: [An extensive empirical study of feature selection metrics
#      for text classification](http://dl.acm.org/citation.cfm?id=944974)
#      and [Rubystats](http://rubystats.rubyforge.org)
#
  class BiNormalSeparation < BaseDiscrete
    # include Ruby statistics libraries
    include Rubystats
        
    private
    
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      @nd ||= Rubystats::NormalDistribution.new
      
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        tpr, fpr = a/(a+c), b/(b+d)
        s = (@nd.get_icdf(tpr) - @nd.get_icdf(fpr)).abs
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::BNS instead of FSelector::BiNormalSeparation
  BNS = BiNormalSeparation
  
  
end # module
