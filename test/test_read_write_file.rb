#
# test read and write file
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# use InformationGain as a feature ranking algorithm
r = FSelector::InformationGain.new

# example 1
#


# read Iris data from CSV file
puts "  read from CSV file"
r.data_from_csv('test/iris.csv')

# perform feature selection if needed

# write data to LibSVM format
puts "  write to LibSVM file"
r.data_to_libsvm('test/iris.libsvm')


# example 2
#


# read Iris data from WEKA ARFF file
puts "  read from WEKA ARFF file"
r.data_from_weka('test/iris.arff')

# perform feature selection if needed

# write data to LibSVM format
puts "  write to LibSVM file"
r.data_to_libsvm('test/iris.libsvm')

puts "<============< #{File.basename(__FILE__)}"
