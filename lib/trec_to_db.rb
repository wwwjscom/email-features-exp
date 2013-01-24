# This script will import the trec qrels
# files to the db.  This speeds up the qrels
# eval process, which is otherwise way too slow
#
# This is a one time script.
require "active_record"
require_relative "../configs/db"
require_relative "../models/qrels"


module TRECToDB

  def self.parse_line(line, &block)
    topic, doc, unknown, rel = line.chomp.gsub(":", " ").split(" ")
    hash = {:topic => topic,
             :doc => doc,
             :batch => unknown,
             :rel => rel
    }
    block.call(hash)
  end


end

DB.connect

File.open("eval/qrels.t10legallearn").each_line do |l|
  TRECToDB.parse_line(l) do |hash|
    Qrel.create(hash)
  end
end
