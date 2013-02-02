class Summarize

  # Path is to a results run stored in the /results folder.
  # i.e.: 
  #   results/01-15-2013_02:27:33__footbal
  def initialize(path)
    @path = path
    self
  end

  def summarize
    read_all_tables
    File.open(@path + "/summarized.table.txt", "w") do |f|
      f.puts "format: recall, precision, f1"
      f.puts "test,10,20,50,100,200,500,1000"
      @tables.each { |t| f.puts t.to_file(:recall)}
      f.puts "test,10,20,50,100,200,500,1000"
      @tables.each { |t| f.puts t.to_file(:precision)}
      f.puts "test,10,20,50,100,200,500,1000"
      @tables.each { |t| f.puts t.to_file(:f1)}
    end
  end

  def self.aggregate_summaries
    topic = "201"
    lines_for = nil
    recall_sums, prec_sums, f1_sums = [], [], []
    arr = nil
    counter = 0

    Dir.entries("./results").each do |e|
      next unless e[/^.+__\d{3}__.+$/]
      if e[/_\d{3}_/].gsub('_','') != topic

        # write results
        write_results(topic, recall_sums, "recall")
        write_results(topic, prec_sums, "prec")
        write_results(topic, f1_sums, "f1")

        # reset vars
        topic = e[/_\d{3}_/].gsub('_','')
        recall_sums, prec_sums, f1_sums = [], [], []
        lines_for = nil
        counter = 0
      end

      File.open("./results/#{e}/summarized.table.txt", 'r').each_line do |l|
        next if l[/^format: /]
        if l[/^test,/]
          case lines_for
          when nil then
            arr = recall_sums
            lines_for = :recall
          when :recall then
            arr = prec_sums
            lines_for = :prec
          when :prec
            arr = f1_sums
            lines_for = :f1
          end
          next
        end

        t_num, _10, _20, _50, _100 = l.split(",")
        t_num = t_num.gsub('t','').to_i
        arr[t_num] ||= [0,0,0,0]
        arr[t_num][0] += _10.to_f  unless _10  == "nan"
        arr[t_num][1] += _20.to_f  unless _20  == "nan"
        arr[t_num][2] += _50.to_f  unless _50  == "nan"
        arr[t_num][3] += _100.to_f unless _100 == "nan"

        counter += 1
      end
    end

    # write results
    write_results(topic, recall_sums, "recall")
    write_results(topic, prec_sums, "prec")
    write_results(topic, f1_sums, "f1")
  end

  private # ------

  # Finds all the table files and parses them.
  def read_all_tables
    @tables = []
    Dir.entries(@path).each do |e|
      next unless e =~ /^t\d+$/
      @table = Table.new(e.to_s)
      parse_table
      @tables << @table
    end
  end

  # Parses an individual table file
  def parse_table
    File.open("#{@path}/#{@table.test_name}/#{@table.test_name}.table.txt").each_line do |l|
      next unless l =~ /^  /
      cols = l.split(/\W{2,}/)
      
      # docs ret column
      @table.new_row(cols[1])
      @table.add(:docs_ret_per, cols[2])
      # relevant column
      @table.add(:relevant_num, cols[3])
      @table.add(:recall, cols[4])
      @table.add(:precision, cols[5])
      @table.add(:f1, cols[6])
      # ignore the rest of the cols
    end
  end

  class Table

    attr_accessor :test_name, :stats

    def initialize(test_name)
      @test_name = test_name
      @stats = []
    end

    def new_row(val)
      @stats << {:docs_ret_num => val}
    end

    def add(key, val)
      @stats.last[key] = val
    end

    def to_file(stat)
      line = String.new(@test_name)
      @stats.size.times { |i| line << ","+ @stats[i][stat.to_sym] }
      line
    end
  end


  private # ---------------
  # Used by aggregate_summaries, not summarize
  def self.write_results(topic, arr, measure)
    File.open("./summary_for_#{topic}_#{measure}.txt", "w") do |f|
      f.puts "test,a,b,c,d"
      arr.each_with_index { |test, index| next if index < 3; f.puts "%s,%s,%s,%s,%s" % [index, test[0], test[1], test[2], test[3]] }
    end
  end
end
