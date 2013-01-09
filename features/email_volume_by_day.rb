require_relative '../models/email'

class VolumeByDay < ActiveRecord::Base
  require 'active_record'

  self.table_name = "email_volume_by_day"
end

# Reset the table
VolumeByDay.delete_all

volume = {}
Email.all_mailbox_names.each do |mailbox|
  mailbox = mailbox.mailbox
  Email.where(:mailbox => mailbox).find_each do |email|
    next unless email.date_time # skip emails missing dates
    date = email.date_time.strftime("%Y-%m-%d")
    volume[date] ||= 0
    volume[date] += 1
  end

  volume.each do |date, count|
    VolumeByDay.create(:mailbox => mailbox, :date => date, :total => count)
  end
end
