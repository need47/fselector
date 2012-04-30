#
# test a single algorithm
# for selecting discrete feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# Accuracy (Acc)
puts "  test Accuracy ..."
r1 = FSelector::Acc.new
r1.data_from_random(100, 2, 10, 3, true)
r1.select_feature_by_rank!('<=3')

# AccuracyBalanced (Acc2)
puts "  test AccuracyBalanced ..."
r2 = FSelector::Acc2.new
r2.data_from_random(100, 2, 10, 3, true)
r2.select_feature_by_rank!('<=3')

# BiNormalSeparation (BNS)
puts "  test BiNormalSeparation ..."
r3 = FSelector::BNS.new
r3.data_from_random(100, 2, 10, 3, true)
r3.select_feature_by_rank!('<=3')

# ChiSquaredTest (CHI)
puts "  test ChiSquaredTest ..."
r4 = FSelector::CHI.new(:yates)
r4.data_from_random(100, 2, 10, 3, true)
r4.select_feature_by_rank!('<=3')

# CorrelationCoefficient (CC)
puts "  test CorrelationCoefficient ..."
r5 = FSelector::CC.new
r5.data_from_random(100, 2, 10, 3, true)
r5.select_feature_by_rank!('<=3')

# DocumentFrequency (DF)
puts "  test DocumentFrequency ..."
r6 = FSelector::DF.new
r6.data_from_random(100, 2, 10, 3, true)
r6.select_feature_by_rank!('<=3')

# F1Measure (F1)
puts "  test F1Measure ..."
r7 = FSelector::F1.new
r7.data_from_random(100, 2, 10, 3, true)
r7.select_feature_by_rank!('<=3')

# FishersExactTest(FET)
puts "  test FishersExactTest ..."
r8 = FSelector::FET.new
r8.data_from_random(100, 2, 10, 3, true)
r8.select_feature_by_rank!('<=3')

# GiniIndex (GI)
puts "  test GiniIndex ..."
r9 = FSelector::GI.new
r9.data_from_random(100, 2, 10, 3, true)
r9.select_feature_by_rank!('<=3')

# GMean (GM)
puts "  test GMean ..."
r10 = FSelector::GM.new
r10.data_from_random(100, 2, 10, 3, true)
r10.select_feature_by_rank!('<=3')

# GSSCoefficient (GSS)
puts "  test GSS ..."
r11 = FSelector::GSS.new
r11.data_from_random(100, 2, 10, 3, true)
r11.select_feature_by_rank!('<=3')

# MatthewsCorrelationCoefficient (MCC)
puts "  test MCC ..."
r12 = FSelector::MCC.new
r12.data_from_random(100, 2, 10, 3, true)
r12.select_feature_by_rank!('<=3')

# McNemarsTest (MN)
puts "  test McNemarsTest ..."
r13 = FSelector::MNT.new(:yates_continuity_correction)
r13.data_from_random(100, 2, 10, 3, true)
r13.select_feature_by_rank!('<=3')

# MutualInformation (MI)
puts "  test MutualInformation ..."
r14 = FSelector::MI.new
r14.data_from_random(100, 2, 10, 3, true)
r14.select_feature_by_rank!('<=3')

# OddsRatio (Odd)
puts "  test OddsRatio ..."
r15 = FSelector::Odd.new
r15.data_from_random(100, 2, 10, 3, true)
r15.select_feature_by_rank!('<=3')

# OddsRatio Numerator (OddN)
puts "  test OddsRatio Numerator ..."
r16 = FSelector::OddN.new
r16.data_from_random(100, 2, 10, 3, true)
r16.select_feature_by_rank!('<=3')

# Power
puts "  test Power ..."
r17 = FSelector::Power.new(5)
r17.data_from_random(100, 2, 10, 3, true)
r17.select_feature_by_rank!('<=3')

# Precision
puts "  test Precision ..."
r18 = FSelector::Precision.new
r18.data_from_random(100, 2, 10, 3, true)
r18.select_feature_by_rank!('<=3')

# ProbabilityRatio (PR)
puts "  test ProbabilityRatio ..."
r19 = FSelector::PR.new
r19.data_from_random(100, 2, 10, 3, true)
r19.select_feature_by_rank!('<=3')

# Random
puts "  test Random ..."
r20 = FSelector::Random.new
r20.data_from_random(100, 2, 10, 3, true)
r20.select_feature_by_rank!('<=3')

# Sensitivity (SN)
puts "  test Sensitivity ..."
r21 = FSelector::SN.new
r21.data_from_random(100, 2, 10, 3, true)
r21.select_feature_by_rank!('<=3')

# Specificity (SP)
puts "  test Specificity ..."
r22 = FSelector::SP.new
r22.data_from_random(100, 2, 10, 3, true)
r22.select_feature_by_rank!('<=3')

# SymmetricalUncertainty (SU)
puts "  test SymmetricalUncertainty ..."
r23 = FSelector::SU.new
r23.data_from_random(100, 2, 10, 3, true)
r23.select_feature_by_rank!('<=3')

puts "<============< #{File.basename(__FILE__)}"
