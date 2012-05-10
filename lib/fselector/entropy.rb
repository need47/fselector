#
# entropy-related functions for discrete data
#
# ref: [Wikipedia](http://en.wikipedia.org/wiki/Mutual_information)
#
module Entropy
  #
  # get the marginal entropy of vector (X)
  #
  #     H(X) = -1 * sigma_i (P(x_i) log2 P(x_i))
  #
  # @param [Array] vecX vector of interest
  # @return [Float] H(X)
   def get_marginal_entropy(vecX)
    h = 0.0
    n = vecX.size.to_f

    vecX.uniq.each do |x_i|
      p = vecX.count(x_i)/n
      h += -1.0 * (p * Math.log2(p))
    end

    h
  end # get_marginal_entropy
  
  
  #
  # get the conditional entropy of vector (X) given another vector (Y)
  #
  #     H(X|Y) = sigma_j (P(y_j) * H(X|y_j))
  #     
  #     where H(X|y_j) = -1 * sigma_i (P(x_i|y_j) log2 P(x_i|y_j))
  #
  # @param [Array] vecX the first vector
  # @param [Array] vecY the second vector
  # @return [Float] H(X|Y)
  # @note vecX and vecY must be of same length
   def get_conditional_entropy(vecX, vecY)
    abort "[#{__FILE__}@#{__LINE__}]: \n"+
          "  two vectors must be of same length" if not vecX.size == vecY.size

    hxy = 0.0
    n = vecX.size.to_f

    vecY.uniq.each do |y_j|
      p1 = vecY.count(y_j)/n

      indices = (0...n).to_a.select { |k| vecY[k] == y_j }
      xvs = vecX.values_at(*indices)
      m = xvs.size.to_f

      xvs.uniq.each do |x_i|
        p2 = xvs.count(x_i)/m

        hxy += -1.0 * p1 * (p2 * Math.log2(p2))
      end
    end

    hxy
  end # get_conditional_entropy
  
  
  #
  # get the joint entropy of vector (X) and vector (Y)
  # 
  #     H(X,Y) = H(Y) + H(X|Y)
  #            = H(X) + H(Y|X)
  #     
  #     i.e. H(X,Y) == H(Y,X)
  #
  # @param [Array] vecX the first vector
  # @param [Array] vecY the second vector
  # @return [Float] H(X,Y)
  # @note vecX and vecY must be of same length
  #
   def get_joint_entropy(vecX, vecY)
    get_marginal_entropy(vecY) + get_conditional_entropy(vecX, vecY)
  end # get_joint_entropy
  
  
  #
  # get the information gain of vector (X) given another vector (Y)
  # 
  #     IG(X;Y) = H(X) - H(X|Y)
  #             = H(Y) - H(Y|X) = IG(Y;X)
  #
  # @param [Array] vecX the first vector
  # @param [Array] vecY the second vector
  # @return [Float] IG(X;Y)
  # @note vecX and vecY must be of same length
  #
   def get_information_gain(vecX, vecY)
    get_marginal_entropy(vecX) - get_conditional_entropy(vecX, vecY)
  end # get_joint_entropy
  
  
  #
  # get the symmetrical uncertainty of vector (X) and vector (Y)
  #
  #                      IG(X;Y)
  #     SU(X;Y) = 2 * -------------
  #                     H(X) + H(Y)
  #
  #                    H(X) - H(X|Y)         H(Y) - H(Y|X)
  #             = 2 * --------------- = 2 * --------------- = SU(Y;X)
  #                     H(X) + H(Y)           H(X) + H(Y)
  #
  # @param [Array] vecX the first vector
  # @param [Array] vecY the second vector
  # @return [Float] SU(X;Y)
  # @note vecX and vecY must be of same length
  #
  def get_symmetrical_uncertainty(vecX, vecY)  
    hx = get_marginal_entropy(vecX)
    hxy = get_conditional_entropy(vecX, vecY)
    hy = get_marginal_entropy(vecY)
    
    su = 0.0
    su = 2*(hx-hxy)/(hx+hy) if not (hx+hy).zero?
    
    su
  end
  
  
end # module
