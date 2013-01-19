require 'rubygems'
require 'active_record'
require 'date'

class EmailVolumeByDay < ActiveRecord::Base

  self.table_name = "email_volume_by_day"

  def self.total_volume_for(mailbox)
    where(:mailbox => mailbox).sum(:total)
  end

  def self.volume_for(mailbox, date)
    where(:mailbox => mailbox).where(:date => DateTime.parse(date)).first
  end

end

