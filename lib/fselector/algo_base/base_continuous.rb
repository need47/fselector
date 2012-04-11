#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# base algorithm for handling continous feature
#
  class BaseContinuous < Base
    # include normalizer
    include Normalizer
    # include discretizer
    include Discretizer
    
    # initialize from an existing data structure
    def initialize(data=nil)
      super(data)
    end
    

  end # class


end # module