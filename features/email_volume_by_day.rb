require_relative 'feature'

class VolumeByDay < Feature 
  self.table_name = "email_volume_by_day"

  # Reset the table
  def self.reset
    VolumeByDay.delete_all
  end

  # Recalculate the stats
  def self.recalc
    super.mailbox_names.each do |mailbox|
      volume = {}
      super.emails_by_mailbox(mailbox) do |email|
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

      self.save_volume(volume)
    end
  end

  def self.save_volume(volume)
      volume.each do |date, volume_hash|
        VolumeByDay.create(:mailbox => mailbox, 
                           :date => date, 
                           :total => volume_hash[:total], 
                           :sent_count => volume_hash[:sent_count], 
                           :received_count => volume_hash[:received_count]
                          )
      end
  end
end
