#
# normalize continuous feature
#
module Normalizer
   # log transformation, requires positive feature values 
   def normalize_by_log!(base=10)
     each_sample do |k, s|
       s.keys.each do |f|
         s[f] = Math.log(s[f], base) if s[f] > 0.0
       end
     end
   end
   
   
   # scale to [min, max], max > min
   def normalize_by_min_max!(min=0.0, max=1.0)
     # first determine min and max for each feature
     f2min_max = {}
          
     each_feature do |f|
       fvs = get_feature_values(f)
       f2min_max[f] = [fvs.min, fvs.max]
     end
     
     # then normalize
     each_sample do |k, s|
       s.keys.each do |f|
         min_v, max_v = f2min_max[f]
         s[f] = min + (s[f]-min_v) * (max-min) / (max_v-min_v)
       end
     end
   end
   
   
   # by z-score
   #
   # ref: [Wikipedia](http://en.wikipedia.org/wiki/Zscore)
   def normalize_by_zscore!
     # first determine mean and sd for each feature
     f2mean_sd = {}
     
     each_feature do |f|
       fvs = get_feature_values(f)
       f2mean_sd[f] = fvs.mean, fvs.sd
     end
     
     # then normalize
     each_sample do |k, s|
       s.keys.each do |f|
         mean, sd = f2mean_sd[f]
         if sd.zero?
           s[f] = 0.0
         else
           s[f] = (s[f]-mean)/sd
         end
       end
     end
   end

  
end # module
