require_relative '../models/email'
require 'pp'

class VolumeByHour < ActiveRecord::Base
  require 'active_record'

  self.table_name = "email_volume_by_hour"
end

# Reset the table
VolumeByHour.delete_all

Email.all_mailbox_names.each do |mailbox|
  volume = Array.new(24){{:total => 0, :sent_count => 0, :received_count => 0}}
  mailbox = mailbox.mailbox
  Email.where(:mailbox => mailbox).find_each do |email|
    next unless email.date_time # skip emails missing dates
    v_hour = volume[email.date_time.hour]

    # Increment hour count
    v_hour[:total] += 1

    # Increment sent/received count
    sent_or_received = email.sent_or_received?
    # These can't be combined because sent_or_received
    # could be nil!
    if sent_or_received == :sent
      v_hour[:sent_count] += 1
    elsif sent_or_received == :received
      v_hour[:received_count] += 1
    end
  end
  
  # Store the results in the database
  volume.each_with_index do |volume_hash, hour|
    VolumeByHour.create(:mailbox => mailbox, :hour => hour, :total => volume_hash[:total], :sent_count => volume_hash[:sent_count], :received_count => volume_hash[:received_count])
  end

end
