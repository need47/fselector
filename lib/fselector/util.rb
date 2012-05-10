#
# add functions to Array class
#
class Array
  # summation
  # @return [Float] sum, no need to use .to_f
  def sum
    self.inject(0.0) { |s, i| s+i }
  end
  
  
  # average (mean)
  # @return [Float] average (mean)
  def ave
    self.sum / self.size
  end
  alias :mean :ave # make mean as an alias of ave
  
  
  # median
  # @return [Float] median
  def median
    len = self.size
    sorted = self.sort
    (len % 2 == 1) ? sorted[len/2] : (sorted[len/2-1]+sorted[len/2]).to_f/2
  end
  
  
  # variance
  # @return [Float] variance
  def var
    u = self.ave
    v2 = self.inject(0.0) { |v, i| v+(i-u)*(i-u) }
    
    v2/(self.size-1)
  end
  
  
  # standard deviation
  # @return [Float] standard deviation
  def sd
    Math.sqrt(self.var)
  end
  
  
  # scale to [min, max]
  #
  # @param [Float] min lower bound
  # @param [Float] max upper bound
  # @return [Array<Float>] scaled numbers
  def to_scale(min=0.0, max=1.0)
    if (min >= max)
      abort "[#{__FILE__}@#{__LINE__}]: \n"+
            "  min must be smaller than max!"
    end
    
    old_min = self.min
    old_max = self.max
  
    self.collect do |v|
      if old_min == old_max
        max
      else
        min + (v-old_min)*(max-min)/(old_max-old_min)
      end
    end
  end
  
  
  # convert to z-score
  #
  # ref: [Wikipedia](http://en.wikipedia.org/wiki/Standard_score)
  #
  # @return [Array<Float>] converted z-scores
  def to_zscore
    ave = self.ave
    sd = self.sd
  
    return self.collect { |v| (v-ave)/sd }
  end
  
  
  # convert to symbol
  # @return [Array<Symbol>] converted symbols
  def to_sym
    self.collect { |x| x.to_sym }
  end
  
  
  # Pearson's correlation coefficient, 
  # two vectors must be of the same length
  #
  # @param [Array] v the second vector
  # @return [Float] Pearson's r
  def pearson_r(v)
    abort "[#{__FILE__}@#{__LINE__}]: \n"+
          "  two vectors must be of the same length!" if self.size != v.size
    
    sm, vm = self.ave, v.ave
    a, b, c = 0.0, 0.0, 0.0
    
    self.each_with_index do |s, i|
      a += (s-sm)*(v[i]-vm)
      b += (s-sm)**2
      c += (v[i]-vm)**2
    end
    
    if b.zero? or c.zero?
      return 0.0
    else
      return a / Math.sqrt(b) / Math.sqrt(c)
    end
  end
  
  
end # Array


#
# add functions to String class
#
class String
  # comment line?
  #
  # @param [String] char line beginning char
  def comment?(char='#')
    return self =~ /^#{char}/
  end


  # blank line?
  def blank?
    return self =~ /^\s*$/
  end
  
  
  #
  # Enhanced String.split with escape char, which means
  # string included in a pair of escape char is considered as a whole
  # even if it matches the split regular expression. this is especially
  # useful to parse CSV file that contains comma in a doube-quoted string
  # e.g. 'a,"b, c",d'.split_me(/,/, '"') => [a, 'b, c', d]
  #
  # @param [Regex] delim_regex regular expression for split
  # @param [String] quote_char quote char such as ' and "
  # @return [Array<String>]
  #
  def split_me(delim_regex, quote_char="'")
    d, q = delim_regex, quote_char
    if not self.count(q) % 2 == 0
      $stderr.puts "unpaired char of #{q} found, return nil"
      return nil
    end
    self.split(/#{d.source} (?=(?:[^#{q}]* #{q} [^#{q}]* #{q})* [^#{q}]*$) /x)
  end
  
  
end # String

#puts "a, 'b,c, d' ,'e'".split_me(/,\s*/, "'")
#=>a
#=>_'b,c, d'_
#=>'e'
