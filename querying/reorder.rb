require_relative '../models/email'
require_relative '../models/email_volume_by_hour'
require_relative '../models/email_volume_by_day'

class Reorder
  def self.these(search, results)
    self.send(search.t_num, results)
  end

  # Reorder based on which test we're running
  def self.t4(results)
    each_result(results) do |r, email|
      t4_t5_helper(email) do |total_vol, hour_vol|
        r[:score] = r[:score].to_f + Math.log(total_vol.to_f / hour_vol.total.to_f)
      end
    end
    results
  end

  def self.t5(results)
    min = 9999999
    each_result(results) do |r, email|
      t4_t5_helper(email) do |total_vol, hour_vol|
        r[:score] = r[:score].to_f + Math.log(hour_vol.total.to_f / total_vol.to_f)
        min = r[:score] if r[:score] < min
      end
    end

    # ensure all scores are >= 0
    results.each {|r| r[:score] += min }
    results
  end

  def self.t6(results)
    each_result(results) do |r, email|
      t6_t7_helper(email) do |total_vol, day_vol|
        r[:score] = r[:score].to_f + Math.log(total_vol.to_f / day_vol.total.to_f)
      end
    end
    results
  end

  def self.t7(results)
    each_result(results) do |r, email|
      t6_t7_helper(email) do |total_vol, day_vol|
        r[:score] = r[:score].to_f + Math.log(day_vol.total.to_f / total_vol.to_f)
      end
    end
    results
  end

  def self.t8(results)
    each_result(results) do |r, email|
      t8_t9_helper(email) do
        r[:score] = r[:score].to_f * email.attachments.size
      end
    end
    results
  end

  def self.t9(results)
    each_result(results) do |r, email|
      t8_t9_helper(email) do
        r[:score] = r[:score].to_f / email.attachments.size
      end
    end
    results
  end

  private #---------------

  def self.each_result(results, &block)
    results.each do |r|
      email = Email.find(r[:email_id])
      block.call(r, email)
    end
  end

  # helpers -------------------
  def self.t4_t5_helper(email, &block)
      return unless email.date_time # skip missing dates
      total_vol = EmailVolumeByHour.total_volume_for(email.mailbox)
      hour_vol  = EmailVolumeByHour.volume_for(email.mailbox, email.date_time.hour)
      return unless total_vol && hour_vol
      block.call(total_vol, hour_vol)
  end

  def self.t6_t7_helper(email, &block)
      return unless email.date # skip missing dates
      total_vol = EmailVolumeByDay.total_volume_for(email.mailbox)
      day_vol   = EmailVolumeByDay.volume_for(email.mailbox, email.date)
      return unless total_vol && day_vol
      block.call(total_vol, day_vol)
  end

  def self.t8_t9_helper(email, &block)
      return unless email.has_attachment? # skip missing dates
      block.call
  end

end
