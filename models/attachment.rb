require 'rubygems'
require 'active_record'

class Attachment < ActiveRecord::Base

  self.table_name = "attachment"
  belongs_to :email

end
