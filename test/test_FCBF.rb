require 'fselector'

puts "\n======= begin test #{File.basename(__FILE__)} ======="

r = FSelector::FCBF.new
r.data_from_csv('test/iris.csv')

# number of features before feature selection
puts '# features (before): ' + r.get_features.size.to_s

# feature selection
r.select_feature!

# number of features after feature selection
puts '# features (after): ' + r.get_features.size.to_s

puts "======= end test #{File.basename(__FILE__)} ======="
