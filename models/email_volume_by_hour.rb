require 'rubygems'
require 'active_record'

class EmailVolumeByHour < ActiveRecord::Base

  self.table_name = "email_volume_by_hour"

  def self.total_volume_for(mailbox)
    where(:mailbox => mailbox).sum(:total)
  end

  def self.volume_for(mailbox, hour)
    where(:mailbox => mailbox).where(:hour => hour).first
  end

end

