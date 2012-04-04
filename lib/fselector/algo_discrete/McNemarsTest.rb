#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
# McNemar's test (MN), based on Chi-Squared test
#
#                 (B-C)^2
#     MN(f, c) = ---------
#                  B+C
#
# suitable for large samples and B+C >= 25
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/McNemar%27s_test)
#
  class McNemarsTest < BaseDiscrete
    #
    # new()
    #
    # @param [Boolean] correction correction Yates's continuity correction  
    #   :yates, Yates's continuity correction
    #
    def initialize(correction=nil, data=nil)
      super(data)
      @correction = (correction==:yates) ? true : false
    end
     
    private
        
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        b, c = get_B(f, k), get_C(f, k)
        
        if b+c < 25
          $stderr.puts "McNemarsTest [warning]:\n  " +
            "Chi-squared approximation may be incorrect"
        end
        
        s = 0.0
        if not (b+c).zero?
          if not @correction
            s = (b-c)**2 / (b+c)
          else
            s = ((b-c).abs-0.5)**2 / (b+c)
          end
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::MNT instead of FSelector::McNemarsTest
  MNT = McNemarsTest
  
  
end # module
