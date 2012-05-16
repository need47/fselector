#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# J-Measure (JM) for discrete feature
#
#                                                 P(y_j|x_i)
#     JM = sigma_i P(x_i) sigma_j P(y_j|x_i) log ------------
#                                                   P(y_j)
#
# ref: [Feature Extraction, Foundations and Applications](http://www.springer.com/engineering/computational+intelligence+and+complexity/book/978-3-540-35487-1)
#
  class JMeasure < BaseDiscrete
    # this algo outputs weight for each feature
    @algo_type = :feature_weighting
        
    private    
    
    # calculate contribution of each feature (f) across all classes
    def calc_contribution(f)
      cv = get_class_labels
      fv = get_feature_values(f, :include_missing_values)
      sz = cv.size.to_f # also equal fv.size
      
      s = 0.0
      fv.uniq.each do |x|
        px = fv.count(x)/sz

        cv.uniq.each do |y|
          py = cv.count(y)/sz
          
          indices = (0...fv.size).to_a.select { |i| fv[i] == x }
          pyx = cv.values_at(*indices).count(y)/indices.size.to_f
          
          s += px * ( pyx * Math.log2(pyx/py) ) if not pyx.zero?
        end
      end
      
      set_feature_score(f, :BEST, s)
    end # calc_contribution
    
    
  end # class
  
  
  # shortcut so that you can use FSelector::JM instead of FSelector::JMeasure
  JM = JMeasure
  
  
end # module
