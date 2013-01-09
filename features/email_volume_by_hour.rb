require_relative '../models/email'
require 'pp'

class VolumeByHour < ActiveRecord::Base
  require 'active_record'

  self.table_name = "email_volume_by_hour"
end

# Reset the table
VolumeByHour.delete_all

Email.all_mailbox_names.each do |mailbox|
  volume = Array.new(24){0}
  mailbox = mailbox.mailbox
  Email.where(:mailbox => mailbox).find_each do |email|
    next unless email.date_time # skip emails missing dates
    volume[email.date_time.hour] += 1
  end
  
  volume.each_with_index do |count, hour|
    VolumeByHour.create(:mailbox => mailbox, :hour => hour, :total => count)
  end

end
