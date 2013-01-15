require_relative '../models/email'
require_relative '../models/header'

class Search

  def self.all_tests(term)
    self.t1(term)
  end

  def self.t1(term)
    Search.new({
        :negative_term => term,
        :negative_boost => 0.0,
        :negative_field => "body",
        :positive_term => term,
        :positive_field => "subject",
        :test_number => "t1"
      }).query
  end

  def initialize(search_hash)
    @n_term  = search_hash[:negative_term]
    @n_boost = search_hash[:negative_boost]
    @n_field = search_hash[:negative_field]
    @p_term  = search_hash[:positive_term]
    @p_field = search_hash[:positive_field]
    @t_num   = search_hash[:test_number]
    self
  end

  def query_framework
    # For some reason the blocks lose scope of the instance vars...
    n_term  = @n_term  
    n_boost = @n_boost 
    n_field = @n_field 
    p_term  = @p_term  
    p_field = @p_field 

    search = Email.search({:page => 1, :per_page => 1000}) do
      query do
        boosting({:negative_boost => n_boost}) { negative { term n_field.to_sym, n_term } }
        boosting { positive { term p_field.to_sym, p_term } }
      end
    end
    search
  end

  def query
    search = query_framework
    File.open("./results/#{@t_num}", "w") do |file|
      search.results.each_with_index do |doc, i|
        file.puts "207 Q0 %s %s %s %s" % [search[i].file_name.gsub('.txt', ''), (i+1).to_s, doc._score.to_s, search[i].id]
      end
    end
  end
end

Search.all_tests("footbal")
