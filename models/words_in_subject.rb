require 'rubygems'
require 'active_record'

class WordsInSubject < ActiveRecord::Base

  self.table_name = "words_in_subject"

  def self.for(email_subject)
    email_subject.split(/s+/).size
  end

end

