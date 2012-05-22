#
# test read and write file
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# use InformationGain as a feature ranking algorithm
r = FSelector::Relief_c.new

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


# example 3
#

# read Iris data online
puts "  read from on-line Iris dataset"
csv_url = "http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"

# supply feature name-type pairs as the dataset from the above url does not specify them
# feature must be in the same order as it appears in the dataset
name2type = {
    :'sepal-length' => :numeric,
    :'sepal-width' => :numeric,
    :'petal-length' => :numeric,
    :'petal-width' => :numeric
}

# read data (CSV file format)
r.data_from_url(csv_url, :csv, :class_label_column=>5, :feature_name2type=>name2type)

# => 150
puts "  numboer of samples read: %d" % r.get_sample_size

puts "<============< #{File.basename(__FILE__)}"
