require_relative '../lib/kernel'
require_relative '../models/email'
require_relative '../models/header'
require_relative 'reorder'

class Search

  attr_accessor :t_num

  def self.all_tests(topic, term)
    #self.t01(topic, term)
    #self.t02(topic, term)
    self.t03(topic, term)
    self.t4_to_tn(topic, term)
  end

  def self.t01(topic, term)
    Search.new({
        :negative_term => term,
        :negative_boost => 0.0,
        :negative_field => "body",
        :positive_term => term,
        :positive_field => "subject",
        :test_number => this_method_name
      }).query(topic)
  end

  def self.t02(topic, term)
    Search.new({
        :negative_term => term,
        :negative_boost => 0.3,
        :negative_field => "subject",
        :positive_term => term,
        :positive_field => "body",
        :test_number => this_method_name
      }).query(topic)
  end

  def self.t03(topic, term)
    Search.new({
        :negative_term => term,
        :negative_boost => 0.3,
        :negative_field => "body",
        :positive_term => term,
        :positive_field => "subject",
        :test_number => this_method_name
      }).query(topic)
  end

  # These can be combined since we don't change the
  # negative or positive boosting
  def self.t4_to_tn(topic, term)
    (4..33).each do |i|
    #(4..40).each do |i|
      log("Setting up tests t%02d" % i)
      Search.new({
        :negative_term => term,
        :negative_boost => 0.3,
        :negative_field => "body",
        :positive_term => term,
        :positive_field => "subject",
        :test_number => "t%02d" % i
      }).query(topic, true)
    end
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
        match :_all, p_term
        #boosting({:negative_boost => n_boost}) { negative { text n_field.to_sym, n_term } }
        #boosting { positive { text p_field.to_sym, p_term } }
      end
    end
    search
  end

  def query(topic, reorder_results = false)
    search = query_framework

    results = search_to_results(search)

    if reorder_results
      Reorder.these(self, results)
    end

    # Resort the array by score so TREC is happy
    results.sort!{|a,b| a[:score] <=> b[:score] }.reverse!

    log "Saving query results for #{@t_num}"
    File.open("./results/#{@t_num}", "w") do |file|
      results.each_with_index do |doc, i|
        file.puts "#{topic} Q0 %s %s %s %s" % [doc[:file_name].gsub('.txt', ''), (i+1).to_s, doc[:score].to_s, doc[:email_id]]
      end
    end
  end


  def search_to_results(search)
    results = []
    search.results.each_with_index do |doc, i|
      results << { 
        :file_name => search[i].file_name.gsub('.txt', ''), 
        :score => doc._score, 
        :email_id => search[i].id
      }
    end
    results
  end
end
