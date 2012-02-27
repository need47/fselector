require File.expand_path(File.dirname(__FILE__) + '/algo_continuous/normalizer.rb')
require File.expand_path(File.dirname(__FILE__) + '/algo_continuous/discretizer.rb')
#
# FSelector: a Ruby gem for feature selection and ranking
#
module FSelector
#
# base ranking algorithm for handling continous feature
#
  class BaseContinuous < Base
    # include normalizer
    include Normalizer
    # include discretilizer
    include Discretilizer
    
    # initialize from an existing data structure
    def initialize(data=nil)
      super(data)
    end
    

  end # class


end # module
