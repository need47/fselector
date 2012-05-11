#
# print the type for each algorithm
#
require 'fselector'

puts "\n>============> #{File.basename(__FILE__)}"

rs = FSelector.constants.collect { |c|
  next if c =~ /Base/ or c =~ /Ensemble/
  r = FSelector.const_get(c)
  next if not Class === r
  r
}.compact.uniq

rs.each do |r|
  puts "%45s  %s" % [r.to_s, r.algo_type]
end

puts "\n>============> #{File.basename(__FILE__)}"
