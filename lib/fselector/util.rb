#
# add functions to Array class
#
class Array
  # summation
  # @return [Float] sum
  def sum
    self.inject(0.0) { |s, i| s+i }
  end
  
  
  # average (mean)
  # @return [Float] average (mean)
  def ave
    self.sum / self.size
  end
  alias :mean :ave # make mean as an alias of ave
  
  
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
  def to_scale(min=0.0, max=1.0)
    if (min >= max)
      abort "[#{__FILE__}@#{__LINE__}]: "+
            "min must be smaller than max"
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
  
  
  # convert to zscore
  #
  # ref: [Wikipedia](http://en.wikipedia.org/wiki/Standard_score)
  def to_zscore
    ave = self.ave
    sd = self.sd
  
    return self.collect { |v| (v-ave)/sd }
  end
  
  
  # to symbol
  # @return [Array<Symbol>] converted symbols
  def to_sym
    self.collect { |x| x.to_sym }
  end
  
  
  # pearson's correlation coefficient
  # two vectors must be of the same length
  def pearson_r(v)
    sm, vm = self.ave, v.ave
    a, b, c = 00, 0.0, 0.0
    
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
  # @param [String] quote quote char such as ' and "
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


#
# adapted from the Ruby statistics libraries --
# [Rubystats](http://rubystats.rubyforge.org)
#
# - for Fisher's exact test (Rubystats::FishersExactTest.calculate())
#   used by algo\_binary/FishersExactText.rb
# - for inverse cumulative normal distribution function (Rubystats::NormalDistribution.get\_icdf())
#   used by algo\_binary/BiNormalSeparation.rb. note the original get\_icdf() function is a private
#   one, so we have to open it up and that's why the codes here.
# 
#
 module Rubystats
  MAX_VALUE = 1.2e290
  SQRT2PI = 2.5066282746310005024157652848110452530069867406099
  SQRT2 = 1.4142135623730950488016887242096980785696718753769
  TWO_PI = 6.2831853071795864769252867665590057683943387987502
  
  #
  # Fisher's exact test calculator
  #
  class FishersExactTest
    # new()
    def initialize
      @sn11    = 0.0
      @sn1_    = 0.0
      @sn_1    = 0.0
      @sn      = 0.0
      @sprob   = 0.0

      @sleft   = 0.0
      @sright  = 0.0 
      @sless   = 0.0 
      @slarg   = 0.0

      @left    = 0.0
      @right   = 0.0
      @twotail = 0.0
    end
    
    
    # Fisher's exact test
    def calculate(n11_,n12_,n21_,n22_)
      n11_ *= -1 if n11_ < 0
      n12_ *= -1 if n12_ < 0
      n21_ *= -1 if n21_ < 0 
      n22_ *= -1 if n22_ < 0 
      n1_     = n11_ + n12_
      n_1     = n11_ + n21_
      n       = n11_ + n12_ + n21_ + n22_
      prob    = exact(n11_,n1_,n_1,n)
      left    = @sless
      right   = @slarg
      twotail = @sleft + @sright
      twotail = 1 if twotail > 1
      values_hash = { :left =>left, :right =>right, :twotail =>twotail }
      return values_hash
    end
    
    private

    # Reference: "Lanczos, C. 'A precision approximation
    # of the gamma function', J. SIAM Numer. Anal., B, 1, 86-96, 1964."
    # Translation of  Alan Miller's FORTRAN-implementation
    # See http://lib.stat.cmu.edu/apstat/245
    def lngamm(z) 
      x = 0
      x += 0.0000001659470187408462/(z+7)
      x += 0.000009934937113930748 /(z+6)
      x -= 0.1385710331296526      /(z+5)
      x += 12.50734324009056       /(z+4)
      x -= 176.6150291498386       /(z+3)
      x += 771.3234287757674       /(z+2)
      x -= 1259.139216722289       /(z+1)
      x += 676.5203681218835       /(z)
      x += 0.9999999999995183

      return(Math.log(x)-5.58106146679532777-z+(z-0.5) * Math.log(z+6.5))
    end

    def lnfact(n)
      if n <= 1
        return 0
      else
        return lngamm(n+1)
      end
    end

    def lnbico(n,k)
      return lnfact(n) - lnfact(k) - lnfact(n-k)
    end

    def hyper_323(n11, n1_, n_1, n)
      return Math.exp(lnbico(n1_, n11) + lnbico(n-n1_, n_1-n11) - lnbico(n, n_1))
    end

    def hyper(n11)
      return hyper0(n11, 0, 0, 0)
    end

    def hyper0(n11i,n1_i,n_1i,ni)
      if n1_i == 0 and n_1i ==0 and ni == 0
        unless n11i % 10 == 0
          if n11i == @sn11+1
            @sprob *= ((@sn1_ - @sn11)/(n11i.to_f))*((@sn_1 - @sn11)/(n11i.to_f + @sn - @sn1_ - @sn_1))
            @sn11 = n11i
            return @sprob
          end
          if n11i == @sn11-1
            @sprob *= ((@sn11)/(@sn1_-n11i.to_f))*((@sn11+@sn-@sn1_-@sn_1)/(@sn_1-n11i.to_f))
            @sn11 = n11i
            return @sprob
          end
        end
        @sn11 = n11i
      else
        @sn11 = n11i
        @sn1_ = n1_i
        @sn_1 = n_1i
        @sn   = ni
      end
      @sprob = hyper_323(@sn11,@sn1_,@sn_1,@sn)
      return @sprob
    end

    def exact(n11,n1_,n_1,n)

      p = i = j = prob = 0.0

      max = n1_
      max = n_1 if n_1 < max
      min = n1_ + n_1 - n
      min = 0 if min < 0

      if min == max
        @sless  = 1
        @sright = 1
        @sleft  = 1
        @slarg  = 1
        return 1
      end

      prob = hyper0(n11,n1_,n_1,n)
      @sleft = 0

      p = hyper(min)
      i = min + 1
      while p < (0.99999999 * prob)
        @sleft += p
        p = hyper(i)
        i += 1
      end

      i -= 1

      if p < (1.00000001*prob)
        @sleft += p
      else 
        i -= 1  
      end

      @sright = 0

      p = hyper(max)
      j = max - 1
      while p < (0.99999999 * prob)
        @sright += p
        p = hyper(j)
        j -= 1
      end
      j += 1

      if p < (1.00000001*prob)
        @sright += p
      else 
        j += 1
      end

      if (i - n11).abs < (j - n11).abs 
        @sless = @sleft
        @slarg = 1 - @sleft + prob
      else
        @sless = 1 - @sright + prob
        @slarg = @sright
      end
      return prob
    end
        
    
  end # class
  
  #
  # Normal distribution
  #
  class NormalDistribution
    # Constructs a normal distribution (defaults to zero mean and
    # unity variance)
    def initialize(mu=0.0, sigma=1.0)
      @mean = mu
      if sigma <= 0.0
        return "error"
      end
      @stdev = sigma
      @variance = sigma**2
      @pdf_denominator = SQRT2PI * Math.sqrt(@variance)
      @cdf_denominator = SQRT2   * Math.sqrt(@variance)
    end

   
    # Obtain single PDF value
    # Returns the probability that a stochastic variable x has the value X,
    # i.e. P(x=X)
    def get_pdf(x)
      Math.exp( -((x-@mean)**2) / (2 * @variance)) / @pdf_denominator
    end
    
    
    # Obtain single CDF value
    # Returns the probability that a stochastic variable x is less than X,
    # i.e. P(x<X)
    def get_cdf(x)
      complementary_error( -(x - @mean) / @cdf_denominator) / 2
    end
    
    
    # Obtain single inverse CDF value.
    # returns the value X for which P(x<X).
    def get_icdf(p)
      check_range(p)
      if p == 0.0
        return -MAX_VALUE
      end
      if p == 1.0
        return MAX_VALUE
      end
      if p == 0.5
      return @mean
      end

      mean_save = @mean
      var_save = @variance
      pdf_D_save = @pdf_denominator
      cdf_D_save = @cdf_denominator
      @mean = 0.0
      @variance = 1.0
      @pdf_denominator = Math.sqrt(TWO_PI)
      @cdf_denominator = SQRT2
      x = find_root(p, 0.0, -100.0, 100.0)
      #scale back
      @mean = mean_save
      @variance = var_save
      @pdf_denominator = pdf_D_save
      @cdf_denominator = cdf_D_save
      return x * Math.sqrt(@variance) + @mean
    end

    private
    
    #check that variable is between lo and hi limits. 
    #lo default is 0.0 and hi default is 1.0
    def check_range(x, lo=0.0, hi=1.0)
      raise ArgumentError.new("x cannot be nil") if x.nil?
      if x < lo or x > hi
        raise ArgumentError.new("x must be less than lo (#{lo}) and greater than hi (#{hi})")
      end
    end


    def find_root(prob, guess, x_lo, x_hi)
      accuracy = 1.0e-10
      max_iteration = 150
      x     = guess
      x_new = guess
      error = 0.0
      _pdf  = 0.0
      dx    = 1000.0
      i     = 0
      while ( dx.abs > accuracy && (i += 1) < max_iteration )
        #Apply Newton-Raphson step
        error = cdf(x) - prob
        if error < 0.0
        x_lo = x
        else
        x_hi = x
        end
        _pdf = pdf(x)
        if _pdf != 0.0
        dx = error / _pdf
        x_new = x -dx
        end
        # If the NR fails to converge (which for example may be the
        # case if the initial guess is too rough) we apply a bisection
        # step to determine a more narrow interval around the root.
        if  x_new < x_lo || x_new > x_hi || _pdf == 0.0
        x_new = (x_lo + x_hi) / 2.0
        dx = x_new - x
        end
        x = x_new
      end
      return x
    end

    
    #Probability density function
    def pdf(x)
      if x.class == Array
        pdf_vals = []
        for i in (0 ... x.length)
          pdf_vals[i] = get_pdf(x[i])
        end
      return pdf_vals
      else
        return get_pdf(x)
      end
    end

    
    #Cummulative distribution function
    def cdf(x)
      if x.class == Array
        cdf_vals = []
        for i in (0...x.size)
          cdf_vals[i] = get_cdf(x[i])
        end
      return cdf_vals
      else
        return get_cdf(x)
      end
    end

    

    # Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
    #
    # Developed at SunSoft, a Sun Microsystems, Inc. business.
    # Permission to use, copy, modify, and distribute this
    # software is freely granted, provided that this notice
    # is preserved.
    #
    #                 x
    #              2      |\
    #     erf(x)  =  ---------  | exp(-t*t)dt
    #            sqrt(pi) \|
    #                 0
    #
    #     erfc(x) =  1-erf(x)
    #  Note that
    #        erf(-x) = -erf(x)
    #        erfc(-x) = 2 - erfc(x)
    #
    # Method:
    #    1. For |x| in [0, 0.84375]
    #        erf(x)  = x + x*R(x^2)
    #          erfc(x) = 1 - erf(x)           if x in [-.84375,0.25]
    #                  = 0.5 + ((0.5-x)-x*R)  if x in [0.25,0.84375]
    #       where R = P/Q where P is an odd poly of degree 8 and
    #       Q is an odd poly of degree 10.
    #                         -57.90
    #            | R - (erf(x)-x)/x | <= 2
    #
    #
    #       Remark. The formula is derived by noting
    #          erf(x) = (2/sqrt(pi))*(x - x^3/3 + x^5/10 - x^7/42 + ....)
    #       and that
    #          2/sqrt(pi) = 1.128379167095512573896158903121545171688
    #       is close to one. The interval is chosen because the fix
    #       point of erf(x) is near 0.6174 (i.e., erf(x)=x when x is
    #       near 0.6174), and by some experiment, 0.84375 is chosen to
    #        guarantee the error is less than one ulp for erf.
    #
    #      2. For |x| in [0.84375,1.25], let s = |x| - 1, and
    #         c = 0.84506291151 rounded to single (24 bits)
    #             erf(x)  = sign(x) * (c  + P1(s)/Q1(s))
    #             erfc(x) = (1-c)  - P1(s)/Q1(s) if x > 0
    #              1+(c+P1(s)/Q1(s))    if x < 0
    #             |P1/Q1 - (erf(|x|)-c)| <= 2**-59.06
    #       Remark: here we use the taylor series expansion at x=1.
    #        erf(1+s) = erf(1) + s*Poly(s)
    #             = 0.845.. + P1(s)/Q1(s)
    #              That is, we use rational approximation to approximate
    #                 erf(1+s) - (c = (single)0.84506291151)
    #            Note that |P1/Q1|< 0.078 for x in [0.84375,1.25]
    #            where
    #             P1(s) = degree 6 poly in s
    #             Q1(s) = degree 6 poly in s
    #
    #           3. For x in [1.25,1/0.35(~2.857143)],
    #                  erfc(x) = (1/x)*exp(-x*x-0.5625+R1/S1)
    #                  erf(x)  = 1 - erfc(x)
    #            where
    #             R1(z) = degree 7 poly in z, (z=1/x^2)
    #             S1(z) = degree 8 poly in z
    #
    #           4. For x in [1/0.35,28]
    #                  erfc(x) = (1/x)*exp(-x*x-0.5625+R2/S2) if x > 0
    #                 = 2.0 - (1/x)*exp(-x*x-0.5625+R2/S2) if -6<x<0
    #                 = 2.0 - tiny        (if x <= -6)
    #                  erf(x)  = sign(x)*(1.0 - erfc(x)) if x < 6, else
    #                  erf(x)  = sign(x)*(1.0 - tiny)
    #            where
    #             R2(z) = degree 6 poly in z, (z=1/x^2)
    #             S2(z) = degree 7 poly in z
    #
    #           Note1:
    #            To compute exp(-x*x-0.5625+R/S), let s be a single
    #            PRECISION number and s := x then
    #             -x*x = -s*s + (s-x)*(s+x)
    #                 exp(-x*x-0.5626+R/S) =
    #                 exp(-s*s-0.5625)*exp((s-x)*(s+x)+R/S)
    #           Note2:
    #            Here 4 and 5 make use of the asymptotic series
    #                   exp(-x*x)
    #             erfc(x) ~ ---------- * ( 1 + Poly(1/x^2) )
    #                   x*sqrt(pi)
    #            We use rational approximation to approximate
    #               g(s)=f(1/x^2) = log(erfc(x)*x) - x*x + 0.5625
    #            Here is the error bound for R1/S1 and R2/S2
    #               |R1/S1 - f(x)|  < 2**(-62.57)
    #               |R2/S2 - f(x)|  < 2**(-61.52)
    #
    #            5. For inf > x >= 28
    #                             erf(x)  = sign(x) *(1 - tiny)  (raise inexact)
    #                             erfc(x) = tiny*tiny (raise underflow) if x > 0
    #                           = 2 - tiny if x<0
    #
    #            7. Special case:
    #                             erf(0)  = 0, erf(inf)  = 1, erf(-inf) = -1,
    #                             erfc(0) = 1, erfc(inf) = 0, erfc(-inf) = 2,
    #                           erfc/erf(NaN) is NaN
    #
    #               $efx8 = 1.02703333676410069053e00
    #
    #                 Coefficients for approximation to erf on [0,0.84375]
    #

    # Error function.
    # Based on C-code for the error function developed at Sun Microsystems.
    # Author:: Jaco van Kooten

    def error(x)
      e_efx = 1.28379167095512586316e-01

      ePp = [ 1.28379167095512558561e-01,
        -3.25042107247001499370e-01,
        -2.84817495755985104766e-02,
        -5.77027029648944159157e-03,
        -2.37630166566501626084e-05 ]

      eQq = [ 3.97917223959155352819e-01,
        6.50222499887672944485e-02,
        5.08130628187576562776e-03,
        1.32494738004321644526e-04,
        -3.96022827877536812320e-06 ]

      # Coefficients for approximation to erf in [0.84375,1.25]
      ePa = [-2.36211856075265944077e-03,
        4.14856118683748331666e-01,
        -3.72207876035701323847e-01,
        3.18346619901161753674e-01,
        -1.10894694282396677476e-01,
        3.54783043256182359371e-02,
        -2.16637559486879084300e-03 ]

      eQa = [ 1.06420880400844228286e-01,
        5.40397917702171048937e-01,
        7.18286544141962662868e-02,
        1.26171219808761642112e-01,
        1.36370839120290507362e-02,
        1.19844998467991074170e-02 ]

      e_erx = 8.45062911510467529297e-01

      abs_x = (if x >= 0.0 then x else -x end)
      # 0 < |x| < 0.84375
      if abs_x < 0.84375
        #|x| < 2**-28
        if abs_x < 3.7252902984619141e-9
        retval = abs_x + abs_x * e_efx
        else
        s = x * x
        p = ePp[0] + s * (ePp[1] + s * (ePp[2] + s * (ePp[3] + s * ePp[4])))

        q = 1.0 + s * (eQq[0] + s * (eQq[1] + s *
        ( eQq[2] + s * (eQq[3] + s * eQq[4]))))
        retval = abs_x + abs_x * (p / q)
        end
      elsif abs_x < 1.25
      s = abs_x - 1.0
      p = ePa[0] + s * (ePa[1] + s *
      (ePa[2] + s * (ePa[3] + s *
      (ePa[4] + s * (ePa[5] + s * ePa[6])))))

      q = 1.0 + s * (eQa[0] + s *
      (eQa[1] + s * (eQa[2] + s *
      (eQa[3] + s * (eQa[4] + s * eQa[5])))))
      retval = e_erx + p / q

      elsif abs_x >= 6.0
      retval = 1.0
      else
        retval = 1.0 - complementary_error(abs_x)
      end
      return (if x >= 0.0 then retval else -retval end)
    end

    # Complementary error function.
    # Based on C-code for the error function developed at Sun Microsystems.
    # author Jaco van Kooten

    def complementary_error(x)
      # Coefficients for approximation of erfc in [1.25,1/.35]

      eRa = [-9.86494403484714822705e-03,
        -6.93858572707181764372e-01,
        -1.05586262253232909814e01,
        -6.23753324503260060396e01,
        -1.62396669462573470355e02,
        -1.84605092906711035994e02,
        -8.12874355063065934246e01,
        -9.81432934416914548592e00 ]

      eSa = [ 1.96512716674392571292e01,
        1.37657754143519042600e02,
        4.34565877475229228821e02,
        6.45387271733267880336e02,
        4.29008140027567833386e02,
        1.08635005541779435134e02,
        6.57024977031928170135e00,
        -6.04244152148580987438e-02 ]

      # Coefficients for approximation to erfc in [1/.35,28]

      eRb = [-9.86494292470009928597e-03,
        -7.99283237680523006574e-01,
        -1.77579549177547519889e01,
        -1.60636384855821916062e02,
        -6.37566443368389627722e02,
        -1.02509513161107724954e03,
        -4.83519191608651397019e02 ]

      eSb = [ 3.03380607434824582924e01,
        3.25792512996573918826e02,
        1.53672958608443695994e03,
        3.19985821950859553908e03,
        2.55305040643316442583e03,
        4.74528541206955367215e02,
        -2.24409524465858183362e01 ]

      abs_x = (if x >= 0.0 then x else -x end)
      if abs_x < 1.25
        retval = 1.0 - error(abs_x)
      elsif abs_x > 28.0
      retval = 0.0

      # 1.25 < |x| < 28
      else
        s = 1.0/(abs_x * abs_x)
        if abs_x < 2.8571428
        r = eRa[0] + s * (eRa[1] + s *
        (eRa[2] + s * (eRa[3] + s * (eRa[4] + s *
        (eRa[5] + s *(eRa[6] + s * eRa[7])
        )))))

        s = 1.0 + s * (eSa[0] + s * (eSa[1] + s *
        (eSa[2] + s * (eSa[3] + s * (eSa[4] + s *
        (eSa[5] + s * (eSa[6] + s * eSa[7])))))))

        else
        r = eRb[0] + s * (eRb[1] + s *
        (eRb[2] + s * (eRb[3] + s * (eRb[4] + s *
        (eRb[5] + s * eRb[6])))))

        s = 1.0 + s * (eSb[0] + s *
        (eSb[1] + s * (eSb[2] + s * (eSb[3] + s *
        (eSb[4] + s * (eSb[5] + s * eSb[6]))))))
        end
        retval =  Math.exp(-x * x - 0.5625 + r/s) / abs_x
      end
      return ( if x >= 0.0 then retval else 2.0 - retval end )
    end

  end # class

end # module
