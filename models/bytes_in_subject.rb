require 'rubygems'
require 'active_record'

class BytesInSubject < ActiveRecord::Base

  self.table_name = "bytes_in_subject"

  def self.for(email_subject)
    email_subject.bytesize
  end

end

