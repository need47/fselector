#
# test example for Information Gain
#
require 'fselector'

puts "\n======= begin test #{File.basename(__FILE__)} ======="

# data1 has two classes(:c0, :c1) and one feature with two discrete vaules (0, 1)
data1 = {
  :c0 => [
    {:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},
    {:f1 => 0}
  ],
  :c1 => [
    {:f1 => 1},
    {:f1 => 1},
    {:f1 => 1},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0}
  ]
}

# data2 has two classes(:c0, :c1) and two binary features
# for :f1, there are 1 and 27 missing cases for :c0 and :c1, respectively 
data2 = {
  :c0 => [
    {:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},
    {:f2 => 1}
  ],
  :c1 => [
    {:f1 => 1},
    {:f1 => 1},
    {:f1 => 1},
    {:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},
    {:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},
    {:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},
    {:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},{:f2 => 1},
  ]
}

# two data sets give exactly the same information gain
r1 = FSelector::IG.new(data1)
puts "IG1 = #{r1.get_feature_scores[:f1][:BEST]}" #=> 0.26503777490949343

r2 = FSelector::IG.new(data2) # discrete data
puts "IG2 = #{r1.get_feature_scores[:f1][:BEST]}" #=> 0.26503777490949343

puts "======= end test #{File.basename(__FILE__)} ======="
