require_relative '../models/email'

class VolumeByDay < ActiveRecord::Base
  require 'active_record'

  self.table_name = "email_volume_by_day"
end

# Reset the table
VolumeByDay.delete_all

Email.all_mailbox_names.each do |mailbox|
  volume = {}
  mailbox = mailbox.mailbox
  Email.where(:mailbox => mailbox).find_each do |email|
    next unless email.date_time # skip emails missing dates
    # Increment dates
    date = email.date_time.strftime("%Y-%m-%d")
    v_date = volume[date] ||= {:total => 0, :sent_count => 0, :received_count => 0}
    v_date[:total] += 1

    # Increment sent/received count
    sent_or_received = email.sent_or_received?
    # These can't be combined because sent_or_received
    # could be nil!
    if sent_or_received == :sent
      v_date[:sent_count] += 1
    elsif sent_or_received == :received
      v_date[:received_count] += 1
    end
  end

  volume.each do |date, volume_hash|
    VolumeByDay.create(:mailbox => mailbox, :date => date, :total => volume_hash[:total], :sent_count => volume_hash[:sent_count], :received_count => volume_hash[:received_count])
  end
end
