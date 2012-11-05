#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# Chi-Squared test (CHI)
#
#                  N * ( P(f,c) * P(f',c') - P(f,c') * P(f',c) )^2
#      CHI(f,c) = -------------------------------------------------
#                           P(f) * P(f') * P(c) * P(c')
#      
#                        N * (A*D - B*C)^2
#               = -------------------------------
#                  (A+B) * (C+D) * (A+C) * (B+D)
#
# suitable for large samples and
# none of the values of (A, B, C, D) < 5
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Chi-squared_test) and [A Comparative Study on Feature Selection Methods for Drug Discovery](http://pubs.acs.org/doi/abs/10.1021/ci049875d)
#
  class ChiSquaredTest < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :filter_by_feature_weighting
    
    #
    # initialize from an existing data structure
    #
    # @param [Boolean] correction use Yates's continuity correction if :yates, 
    #   no correction otherwise
    #
    def initialize(correction=:yates, data=nil)
      super(data)
      
      @correction = (correction==:yates) ? true : false
    end
     
    
    private
        
    # calculate contribution of each feature (f) for each class (k)
    def calc_contribution(f)
      each_class do |k|
        a, b, c, d = get_A(f, k), get_B(f, k), get_C(f, k), get_D(f, k)
        n = a+b+c+d
        
        if a<5 or b<5 or c<5 or d<5
          $stderr.puts "ChiSquaredTest [warning]:\n  " +
            "Chi-squared approximation may be incorrect"
        end
        
        s = 0.0
        x = (a+b)*(c+d)*(a+c)*(b+d)
        
        if not x.zero?
          if not @correction
            s = n * ((a*d-b*c)**2) / x
          else
            s = n * (((a*d-b*c).abs - n/2))**2 / x
          end
        end
        
        set_feature_score(f, k, s)
      end
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::CHI instead of FSelector::ChiSquaredTest
  CHI = ChiSquaredTest
  
  
end # module
