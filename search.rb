require_relative 'email'

#query = "body: friended"
query = 'custom_boost_factor : { query: { friended }, boost_factor: 5.2 }'
query = <<-END
END

#puts "Query: %s" % query
#search = Email.search query

search = Email.search do
  #query { match :body, "friended" }
  query do
    boosting({:negative_boost => 0.0}) { negative { term :subject, "enron" } }
    boosting { positive { term :body, "enron" } }
  end
end

puts "%s %s" % ["Doc ID".ljust(10), "Score".ljust(10)]
puts "-"*50
search.results.each_with_index do |doc, i|
  puts "%s %s %s" % [doc.id.ljust(10), doc._score, search[i].body]
end
