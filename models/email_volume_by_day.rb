require 'rubygems'
require 'active_record'

class EmailVolumeByDay < ActiveRecord::Base

  self.table_name = "email_volume_by_day"

end

