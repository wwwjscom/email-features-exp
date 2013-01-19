require_relative '../models/email'
require_relative '../models/email_volume_by_hour'

class Reorder
  def self.these(search, results)
    case search.t_num
      when "t4" then t4(results)
      when "t5" then t5(results)
    end
  end

  # Reorder based on which test we're running
  def self.t4(results)
    results.each do |r|
      email = Email.find(r[:email_id])
      next unless email.date_time # skip missing dates
      total_vol = EmailVolumeByHour.total_volume_for(email.mailbox)
      hour_vol  = EmailVolumeByHour.volume_for(email.mailbox, email.date_time.hour)
      r[:score] = r[:score].to_f + Math.log(total_vol.to_f / hour_vol.total.to_f)
    end
    results
  end

  def self.t5(results)
    min = 9999999
    results.each do |r|
      email = Email.find(r[:email_id])
      next unless email.date_time # skip missing dates

      total_vol = EmailVolumeByHour.total_volume_for(email.mailbox)
      hour_vol  = EmailVolumeByHour.volume_for(email.mailbox, email.date_time.hour)

      r[:score] = r[:score].to_f + Math.log(hour_vol.total.to_f / total_vol.to_f)

      min = r[:score] if r[:score] < min
    end

    # ensure all scores are >= 0
    results.each {|r| r[:score] += min }

    results
  end

end
