#
# test a single algorithm
# for selecting continuous feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# PMetric (PM)
puts "  test PMetric ..."
r1 = FSelector::PM.new
r1.data_from_random(100, 2, 10, 0, false)
r1.select_feature_by_rank!('<=3')

# TScore (TS)
puts "  test TScore ..."
r2 = FSelector::TS.new
r2.data_from_random(100, 2, 10, 0, true)
r2.select_feature_by_rank!('<=3')

puts "<============< #{File.basename(__FILE__)}"
