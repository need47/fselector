#
# test Information Gain (IG) algorithm
# for selecting discrete feature
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

# data1 has two classes(:c0, :c1) and 
# one feature (:f1) with two discrete vaules (0, 1)
data1 = {
  :c1 => [
    {:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},
    {:f1 => 0}
  ],
  :c2 => [
    {:f1 => 1},
    {:f1 => 1},
    {:f1 => 1},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},
    {:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0},{:f1 => 0}
  ]
}

# data2 has two classes(:c1, :c2) and two binary features
# for :f1, there are 1 and 27 missing cases for :c1 and :c2, respectively 
data2 = {
  :c1 => [
    {:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},{:f1 => 1},
    {:f2 => 1}
  ],
  :c2 => [
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

# example 1
#


r1 = FSelector::IG.new(data1)
puts "  IG1(f1) = #{r1.get_feature_scores[:f1][:BEST]}" #=> 0.26503777490949343


# example 2
#


r2 = FSelector::IG.new(data2) # discrete data
puts "  IG2(f1) = #{r2.get_feature_scores[:f1][:BEST]}" #=> 0.26503777490949343

puts "<============< #{File.basename(__FILE__)}"
