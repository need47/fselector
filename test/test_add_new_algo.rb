#
# test how to add user-defined algorithms
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

module FSelector
  # create a new algorithm belonging to the type of feature weighting
  # to this end, simply override the calc_contribution() in Base class
  class NewAlgo_Weight < Base
    # set the algorithm type
    @algo_type = :feature_weighting
    
    # add your own initialize() here if necessary
    
    private
    
    # the algorithm assigns feature weight randomly
    def calc_contribution(f)
      s = rand
      
      # set the score (s) of feature (f) for class (:BEST is the best score among all classes)
      set_feature_score(f, :BEST, s)
    end
  end # NewAlgo_Weight
  
  
  # create a new algorithm belonging to the type of feature subset selection
  # to this end, simly override the get_feature_subset() in Base class
  class NewAlgo_Subset < Base
    # set the algorithm type
    @algo_type = :feature_subset_selection
    
    # add your own initialize() here if necessary
    
    private
    
    # the algorithm returns a random half-size subset of the orignal one
    def get_feature_subset
      org_features = get_features
      subset = org_features.sample(org_features.size/2)
      
      subset
    end
    
  end # NewAlgo_Subset
end # module


# test
require 'fselector'

# example 1
#

# use NewAlgo_Weighting
r1 = FSelector::NewAlgo_Weight.new
r1.data_from_csv('test/iris.csv')
r1.select_feature_by_rank!('<=2')
puts r1.get_features.join(', ')

# example 2
#

# use NewAlgo_Subset
r2 = FSelector::NewAlgo_Subset.new
r2.data_from_csv('test/iris.csv')
r2.select_feature!
puts r2.get_features.join(', ')

puts "<============< #{File.basename(__FILE__)}"
