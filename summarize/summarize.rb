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

end
