require 'rubygems'
require 'active_record'

class BytesInBody < ActiveRecord::Base

  self.table_name = "bytes_in_body"

  def self.for(email_body)
    email_body.bytesize
  end
end

