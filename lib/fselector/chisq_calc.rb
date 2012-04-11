#
# Chi-Square Calculator
#
# This module is adpated from the on-line [Chi-square Calculator](http://www.swogstat.org/stat/public/chisq_calculator.htm)
#
# The functions for calculating normal and chi-square probabilities 
# and critical values were adapted by John Walker from C implementations 
# written by Gary Perlman of Wang Institute, Tyngsboro, MA 01879. The 
# original C code is in the public domain.
#
# chisq2pval(chisq, df) -- calculate p-value from given 
#                   chi-square value (chisq) and degree of freedom (df)  
# pval2chisq(pval, df) -- chi-square value from given
#                   p-value (pvalue) and degree of freedom (df)
#
module ChiSquareCalculator
  BIGX = 20.0 # max value to represent exp(x)
  LOG_SQRT_PI = 0.5723649429247000870717135 # log(sqrt(pi))
  I_SQRT_PI = 0.5641895835477562869480795 # 1 / sqrt(pi)
  Z_MAX = 6.0 # Maximum meaningful z value
  CHI_EPSILON = 0.000001 # Accuracy of critchi approximation
  CHI_MAX = 99999.0 # Maximum chi-square value
  
  #
  # POCHISQ  --  probability of chi-square value
  #
  # Adapted from:
  #
  #   Hill, I. D. and Pike, M. C.  Algorithm 299
  #
  #   Collected Algorithms for the CACM 1967 p. 243
  #
  # Updated for rounding errors based on remark in
  #
  #   ACM TOMS June 1985, page 185
  #
  # @param [Float] x chi-square value
  # @param [Integer] df degree of freedom
  # @return [Float] p-value
  def pochisq(x, df)
    a, y, s = nil, nil, nil
    e, c, z = nil, nil, nil
    
    even = nil # True if df is an even number
    
    if x <= 0.0 or df < 1
      return 1.0
    end
    
    a = 0.5 * x
    even = ((df & 1) == 0)
    
    if df > 1
      y = ex(-a)
    end
    
    s = even ? y : (2.0 * poz(-Math.sqrt(x)))
    
    if df > 2
      x = 0.5 * (df - 1.0)
      z = even ? 1.0 : 0.5
      
      if a > BIGX
        e = even ? 0.0 : LOG_SQRT_PI
        c = Math.log(a)
        
        while z <= x
          e = Math.log(z) + e
          s += ex(c * z - a - e)
          z += 1.0
        end
        
        return s 
      else
        e = even ? 1.0 : (I_SQRT_PI / Math.sqrt(a))
        c = 0.0
        
        while (z <= x)
          e = e * (a / z)
          c = c + e
          z += 1.0
        end
        
        return c * y + s
      end
    else
      return s
    end
  
  end # pochisq
  
  # function alias
  alias :chisq2pval :pochisq
  
  
  #
  # CRITCHI  --  Compute critical chi-square value to
  # produce given p.  We just do a bisection
  # search for a value within CHI_EPSILON,
  # relying on the monotonicity of pochisq()
  #
  # @param [Float] p p-value
  # @param [Integer] df degree of freedom
  # @return [Float] chi-square value
  def critchi(p, df)
    minchisq = 0.0
    maxchisq = CHI_MAX
    
    chisqval = nil
    
    if p <= 0.0
      return maxchisq
    else
      if p >= 1.0
        return 0.0
      end
    end
    
    chisqval = df / Math.sqrt(p);    # fair first value

    while (maxchisq - minchisq) > CHI_EPSILON
      if pochisq(chisqval, df) < p
        maxchisq = chisqval
      else
        minchisq = chisqval
      end
      
      chisqval = (maxchisq + minchisq) * 0.5
     end
     
     return chisqval
  end # critchi
  
  # function alias
  alias :pval2chisq :critchi
  
  private
  
  def ex(x)
    return (x < -BIGX) ? 0.0 : Math.exp(x)
  end # ex
  
  
  #
  # POZ  --  probability of normal z value
  #
  # Adapted from a polynomial approximation in:
  #  Ibbetson D, Algorithm 209
  #  Collected Algorithms of the CACM 1963 p. 616
  #
  # Note:
  #   This routine has six digit accuracy, so it is only useful for absolute
  #   z values < 6.  For z values >= to 6.0, poz() returns 0.0
  #
   def poz(z)
    y, x, w = nil, nil, nil

    if (z == 0.0)
      x = 0.0
    else
      y = 0.5 * z.abs # Math.abs(z)

      if (y >= (Z_MAX * 0.5))
        x = 1.0
      elsif (y < 1.0)
        w = y * y
        x = ((((((((0.000124818987 * w - 0.001075204047) * w + 
            0.005198775019) * w - 0.019198292004) * w + 
            0.059054035642) * w - 0.151968751364) * w + 
            0.319152932694) * w - 0.531923007300) * w + 
            0.797884560593) * y * 2.0
      else
        y -= 2.0
        x = (((((((((((((-0.000045255659 * y + 
            0.000152529290) * y - 0.000019538132) * y - 
            0.000676904986) * y + 0.001390604284) * y - 
            0.000794620820) * y - 0.002034254874) * y + 
            0.006549791214) * y - 0.010557625006) * y + 
            0.011630447319) * y - 0.009279453341) * y + 
            0.005353579108) * y - 0.002141268741) * y + 
            0.000535310849) * y + 0.999936657524
      end
    end

    return z > 0.0 ? ((x + 1.0) * 0.5) : ((1.0 - x) * 0.5)
  end # poz
  
  
end # module
