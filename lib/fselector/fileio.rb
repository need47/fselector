#
# read and write various file formats, 
# the internal data structure looks like:  
#      
#     data = {
#     
#       :c1 => [                             # class c1
#         {:f1=>1, :f2=>2}                   # sample 2
#       ],
#       
#       :c2 => [                             # class c2
#         {:f1=>1, :f3=>3},                  # sample 1
#         {:f2=>2}                           # sample 3
#       ]
#       
#     }
#     
#     where :c1 and :c2 are class labels; :f1, :f2, and :f3 are features
#
# @note class labels and features are treated as symbols
#
module FileIO
  #
  # read from random data (for test)
  #
  # @param [Integer] nsample number of total samples
  # @param [Integer] nclass number of classes
  # @param [Integer] nfeature number of features
  # @param [Integer] ncategory number of categories for each feature  
  #  1 => binary feature with only on bit  
  #  >1 => discrete feature with multiple values  
  #  otherwise => continuous feature with vaule in the range of [0, 1)
  # @param [true, false] allow_mv whether missing value of feature is alowed or not
  #
  def data_from_random(nsample=100, nclass=2, nfeature=10, ncategory=2, allow_mv=true)
    data = {}
  
    nsample.times do
      k = "c#{rand(nclass)+1}".to_sym
      
      data[k] = [] if not data.has_key? k
      
      feats = {}
      fs = (1..nfeature).to_a
      
      if allow_mv
        (rand(nfeature)).times do
          v = fs[rand(fs.size)]
          fs.delete(v)
        end
      end
      
      fs.sort.each do |i|
        f = "f#{i}".to_sym
        if ncategory == 1
          feats[f] = 1
        elsif ncategory > 1
          feats[f] = rand(ncategory)+1
        else
          feats[f] = rand
        end
      end
      
      data[k] << feats
    end

    set_data(data)
  end # data_from_random
  
  
  #
  # read from libsvm
  #
  # file has the following format  
  # +1  2:1 4:1 ...  
  # -1  3:1 4:1 ...  
  # ....
  #
  # @param [String] fname file to read from  
  #   :stdin => read from standard input instead of file
  #
  def data_from_libsvm(fname=:stdin)
    data = {}
    
    if fname == :stdin
      ifs = $stdin
    elsif not File.exists? fname
      abort "[#{__FILE__}@#{__LINE__}]: "+
            "File '#{fname}' does not exist!"
    else
      ifs = File.open(fname)
    end
    
    ifs.each_line do |ln|
      label, *features = ln.chomp.split(/\s+/)
      label = label.to_sym
      data[label] = [] if not data.has_key? label
      
      feats = {}
      features.each do |fv|
        f, v = fv.split(/:/)
        feats[f.to_sym] = v.to_f
      end
      
      data[label] << feats
    end
    
    # close file
    ifs.close if not ifs == $stdin
    
    set_data(data)
  end # data_from_libsvm
  
  
  #
  # write to libsvm
  #
  # @param [String] fname file to write  
  #   :stdout => write to standard ouput instead of file
  #
  def data_to_libsvm(fname=:stdout)
    if fname == :stdout
      ofs = $stdout
    else
      ofs = File.open(fname, 'w')
    end
    
    # convert class label to integer type
    k2idx = {}
    get_classes.each_with_index do |k, i|
      k2idx[k] = i+1
    end
    
    # convert feature to integer type
    f2idx = {}
    get_features.each_with_index do |f, i|
      f2idx[f] = i+1
    end
    
    each_sample do |k, s|
      ofs.print "#{k2idx[k]} "
      s.keys.sort { |x, y| x.to_s.to_i <=> y.to_s.to_i }.each do |i|
        ofs.print " #{f2idx[i]}:#{s[i]}" if not s[i].zero? # implicit mode
      end
      ofs.puts
    end
    
    # close file
    ofs.close if not ofs == $stdout
  end # data_to_libsvm
  
  
  #
  # read from csv
  #
  # file should have the format with the first two rows
  # specifying features and their data types e.g.  
  # feat1,feat2,...,featn  
  # data\_type1,data\_type2,...,data\_typen  
  # 
  # and the remaing rows showing data e.g.  
  # class\_label,feat\_value1,feat\_value2,...,feat\_value3  
  # ...  
  # 
  # allowed data types are:  
  # INTEGER, REAL, NUMERIC, CONTINUOUS, STRING, NOMINAL, CATEGORICAL
  #
  # @param [String] fname file to read from  
  #   :stdin => read from standard input instead of file
  #
  # @note missing values allowed
  #
  def data_from_csv(fname=:stdin)
    data = {}
    
    if fname == :stdin
      ifs = $stdin
    elsif not File.exists? fname
      abort "[#{__FILE__}@#{__LINE__}]: "+
            "File '#{fname}' does not exist!"
    else
      ifs = File.open(fname)
    end
    
    first_row, second_row = true, true
    feats, types = [], []
    
    ifs.each_line do |ln|
      if first_row # first row
        first_row = false
        *feats = ln.chomp.split(/,/).to_sym
      elsif second_row # second row
        second_row = false
        *types = ln.chomp.split(/,/)
        if types.size == feats.size
          types.each_with_index do |t, i|
            set_opt(feats[i], t.upcase) # record data type
          end
        else
          abort "[#{__FILE__}@#{__LINE__}]: "+
                "the first two rows must have same number of fields"
        end
      else # data rows
        label, *fvs = ln.chomp.split(/,/)
        label = label.to_sym
        data[label] = [] if not data.has_key? label
        
        fs = {}
        fvs.each_with_index do |v, i|
          next if v.empty? # missing value
          data_type = get_opt(feats[i])
          if data_type == 'INTEGER'
            v = v.to_i
          elsif ['REAL', 'NUMERIC', 'CONTINUOUS'].include? data_type
            v = v.to_f
          elsif ['STRING', 'NOMINAL', 'CATEGORICAL'].include? data_type
            #
          else
            abort "[#{__FILE__}@#{__LINE__}]: "+
                  "please specify correct data type "+
                  "for each feature in the 2nd row"
          end
          
          fs[feats[i]] = v
        end
        
        data[label] << fs
      end
    end
    
    # close file
    ifs.close if not ifs == $stdin
    
    set_data(data)
  end # data_from_csv
  
  
  #
  # write to csv
  #
  # file has the format with the first two rows
  # specifying features and their data types
  # and the remaing rows showing data
  #
  # @param [String] fname file to write  
  #   :stdout => write to standard ouput instead of file
  #
  def data_to_csv(fname=:stdout)
    if fname == :stdout
      ofs = $stdout
    else
      ofs = File.open(fname, 'w')
    end
     
    ofs.puts get_features.join(',')
    ofs.puts get_features.collect { |f| 
      get_opt(f) || 'STRING'
    }.join(',')
    
    each_sample do |k, s|
      ofs.print "#{k}"
      each_feature do |f|
        if s.has_key? f
          ofs.print ",#{s[f]}"
        else
          ofs.print ","
        end
      end
      ofs.puts
    end
    
    # close file
    ofs.close if not ofs == $stdout    
  end # data_to_csv
  
  
  #
  # read from WEKA ARFF file
  #
  # @param [String] fname file to read from  
  #   :stdin => read from standard input instead of file
  # @note it's ok if string containes spaces quoted by quote_char
  #
  def data_from_weka(fname=:stdin, quote_char='"')
    data = {}
    
    if fname == :stdin
      ifs = $stdin
    elsif not File.exists? fname
      abort "[#{__FILE__}@#{__LINE__}]: "+
            "File '#{fname}' does not exist!"
    else
      ifs = File.open(fname)
    end
    
    features, classes, comments = [], [], []
    has_class, has_data = false, false
    
    ifs.each_line do |ln|
      next if ln.blank? # blank lines
      
      ln = ln.chomp
      
      # comment line
      if ln.comment?('%')
        comments << ln
      # relation
      elsif ln =~ /^@RELATION/i
        tmp, relation = ln.split_me(/\s+/, quote_char)
        set_opt('@RELATION', relation)
      # class attribute
      elsif ln =~ /^@ATTRIBUTE\s+class\s+{(.+)}/i
        has_class = true
        classes = $1.split_me(/,\s*/, quote_char).to_sym
        classes.each { |k| data[k] = [] }
      # feature attribute (nominal)
      elsif ln =~ /^@ATTRIBUTE\s+(\S+)\s+{(.+)}/i
        f = $1.to_sym
        features << f
        #$2.split_me(/,\s*/, quote_char) # feature nominal values
        set_opt(f, 'NOMINAL')
      # feature attribute (integer, real, numeric, string, date)
      elsif ln =~ /^@ATTRIBUTE/i
        tmp, v1, v2 = ln.split_me(/\s+/, quote_char)
        f = v1.to_sym
        features << f
        set_opt(f, v2.upcase) # record feature data type
      # data header
      elsif ln =~ /^@DATA/i
        has_data = true
      # data
      elsif has_data and has_class
        # read data section
        if ln =~ /^{(.+)}$/ # sparse ARFF
          feats = $1.split_me(/,\s*/, quote_char)
          label = feats.pop.split_me(/\s+/, quote_char)[1]
          label = label.to_sym
          
          fs = {}
          nonzero_fi = []
          feats.each do |fi_fv|
            fi, fv = fi_fv.split_me(/\s+/, quote_char)
            fi = fi.to_i             
            add_feature_weka(fs, features[fi], fv)
            nonzero_fi << fi
          end
          
          # feature with zero value
          features.each_with_index do |f0, i|
            add_feature_weka(fs, f0, 0) if not nonzero_fi.include?(i)
          end
          
          data[label] << fs
        else # regular ARFF
          feats = ln.split_me(/,\s*/, quote_char)
          label = feats.pop.to_sym
          
          fs = {}
          feats.each_with_index do |fv, i|
            add_feature_weka(fs, features[i], fv)
          end
          
          data[label] << fs if label
        end
      else
        next
      end
    end
    
    # close file
    ifs.close if not ifs == $stdin
    
    set_data(data)
    set_classes(classes)
    set_features(features)
    set_opt('COMMENTS', comments) if not comments.empty?
  end # data_from_weak
  
  
  #
  # write to WEKA ARFF file
  #
  # @param [String] fname file to write  
  #   :stdout => write to standard ouput instead of file
  # @param [Symbol] format sparse or regular ARFF  
  #   :sparse => sparse ARFF, otherwise regular ARFF
  #
  def data_to_weka(fname=:stdout, format=:sparse)
    if fname == :stdout
      ofs = $stdout
    else
      ofs = File.open(fname, 'w')
    end
    
    # comments
    comments = get_opt('COMMENTS')
    if comments
      ofs.puts comments.join("\n")
      ofs.puts
    end         
    
    # relation
    relation = get_opt('@RELATION')
    if relation
      ofs.puts "@RELATION #{relation}"
    else
      ofs.puts "@RELATION data_gen_by_FSelector"
    end
    
    ofs.puts
    
    # feature attribute
    each_feature do |f|
      ofs.print "@ATTRIBUTE #{f} "
      type = get_opt(f)
      if type
        if type == 'NOMINAL'
          ofs.puts "{#{get_feature_values(f).uniq.sort.join(',')}}"
        else
          ofs.puts type
        end
      else # treat all other data types as string
        ofs.puts "STRING"
      end
    end
    
    # class attribute
    ofs.puts "@ATTRIBUTE class {#{get_classes.join(',')}}"
    
    ofs.puts
    
    # data header
    ofs.puts "@DATA"
    each_sample do |k, s|
      if format == :sparse # sparse ARFF
        ofs.print "{"
        get_features.each_with_index do |f, i|
          if s.has_key? f
            ofs.print "#{i} #{s[f]}," if not s[f].zero?
          else # missing value
            ofs.print "#{i} ?,"
          end
        end
        ofs.print "#{get_features.size} #{k}"
        ofs.puts "}"
      else # regular ARFF
        each_feature do |f|
          if s.has_key? f
            ofs.print "#{s[f]},"
          else # missing value
            ofs.print "?,"
          end
        end
        ofs.puts "#{k}"
      end
    end
    
    # close file
    ofs.close if not ofs == $stdout
  end
  
  private
  
  # handle and add each feature for WEKA format
  def add_feature_weka(fs, f, v)
    if v == '?' # missing value
      return
    elsif get_opt(f) == 'INTEGER'
      fs[f] = v.to_i
    elsif get_opt(f) == 'REAL' or get_opt(f) == 'NUMERIC'
      fs[f] = v.to_f
    elsif get_opt(f) == 'STRING' or get_opt(f) == 'NOMINAL'
      fs[f] = v
    elsif get_opt(f) == 'DATE' # convert into integer
      fs[f] = (DateTime.parse(v)-DateTime.new(1970,1,1)).to_i
    else
       return
    end
  end # add_feature
     
 
end # module
