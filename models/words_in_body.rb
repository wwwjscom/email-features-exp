require 'rubygems'
require 'active_record'

class WordsInBody < ActiveRecord::Base

  self.table_name = "words_in_body"

  # Returns the number of words found in the email body
  def self.for(email_body)
    email_body.split(/s+/).size
  end
end

