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

# BetweenWithinClassesSumOfSquare (BSS_WSS)
puts "  test BSS_WSS ..."
r3 = FSelector::BSS_WSS.new
r3.data_from_random(100, 2, 10, 0, true)
r3.select_feature_by_rank!('<=3')

# WilcoxonRankSum (WRS)
puts "  test WRS ..."
r4 = FSelector::WRS.new
r4.data_from_random(100, 2, 10, 0, false)
r4.select_feature_by_rank!('<=3')

# F-Test (Ft)
puts "  test FT ..."
r5 = FSelector::FT.new
r5.data_from_random(100, 2, 10, 0, false)
r5.select_feature_by_rank!('<=3')


puts "<============< #{File.basename(__FILE__)}"
