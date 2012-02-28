#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# (two-sided) Fisher's Exact Test (FET)
# 
#          (A+B)! * (C+D)! * (A+C)! * (B+D)!  
#     p =  -----------------------------------
#                  A! * B! * C! * D!
#     
#     for FET, the smaller, the better, but we intentionally negate it
#     so that the larger is always the better (consistent with other algorithms)
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Fisher's_exact_test) and [Rubystats](http://rubystats.rubyforge.org)
#
  class FishersExactTest < BaseDiscrete
    # include Ruby statistics libraries
    include Rubystats
        
    private
        
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      @fet ||= Rubystats::FishersExactTest.new
      
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        
        # note: we've intentionally negated it
        s = -1 * @fet.calculate(a, b, c, d)[:twotail]
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::FET instead of FSelector::FishersExactTest
  FET = FishersExactTest
  
  
end # module
