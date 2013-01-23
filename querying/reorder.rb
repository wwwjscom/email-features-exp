require_relative '../models/email'
require_relative '../models/email_volume_by_hour'
require_relative '../models/email_volume_by_day'
require_relative '../models/bytes_in_body'
require_relative '../models/words_in_body'
require_relative '../models/bytes_in_subject'
require_relative '../models/words_in_subject'

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

  def self.t10(results)
    each_result(results) do |r, email|
      t10_t13_helper(email) do |avg|
        r[:score] = r[:score].to_f + Math.log(avg)
      end
    end
    results
  end

  def self.t11(results)
    each_result(results) do |r, email|
      t10_t13_helper(email) do |avg|
        r[:score] = r[:score].to_f - Math.log(Math.log(avg))
      end
    end
    results
  end

  def self.t12(results)
    each_result(results) do |r, email|
      t10_t13_helper(email) do |avg|
        r[:score] = r[:score].to_f + (email.bytes_in_body.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t13(results)
    each_result(results) do |r, email|
      t10_t13_helper(email) do |avg|
        r[:score] = r[:score].to_f - (email.bytes_in_body.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t14(results)
    each_result(results) do |r, email|
      t14_t17_helper(email) do |avg|
        r[:score] = r[:score].to_f + Math.log(avg)
      end
    end
    results
  end

  def self.t15(results)
    each_result(results) do |r, email|
      t14_t17_helper(email) do |avg|
        r[:score] = r[:score].to_f - Math.log(Math.log(avg))
      end
    end
    results
  end

  def self.t16(results)
    each_result(results) do |r, email|
      t14_t17_helper(email) do |avg, words_in_body|
        r[:score] = r[:score].to_f + (words_in_body.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t17(results)
    each_result(results) do |r, email|
      t14_t17_helper(email) do |avg, words_in_body|
        r[:score] = r[:score].to_f - (words_in_body.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t18(results)
    each_result(results) do |r, email|
      t18_t21_helper(email) do |avg|
        r[:score] = r[:score].to_f + Math.log(avg)
      end
    end
    results
  end

  def self.t19(results)
    each_result(results) do |r, email|
      t18_t21_helper(email) do |avg|
        r[:score] = r[:score].to_f - Math.log(Math.log(avg))
      end
    end
    results
  end

  def self.t20(results)
    each_result(results) do |r, email|
      t18_t21_helper(email) do |avg, bytes_in_subject|
        r[:score] = r[:score].to_f + (bytes_in_subject.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t21(results)
    each_result(results) do |r, email|
      t18_t21_helper(email) do |avg, bytes_in_subject|
        r[:score] = r[:score].to_f - (bytes_in_subject.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t22(results)
    each_result(results) do |r, email|
      t22_t25_helper(email) do |avg|
        r[:score] = r[:score].to_f + Math.log(avg)
      end
    end
    results
  end

  def self.t23(results)
    each_result(results) do |r, email|
      t22_t25_helper(email) do |avg|
        r[:score] = r[:score].to_f - Math.log(Math.log(avg))
      end
    end
    results
  end

  def self.t24(results)
    each_result(results) do |r, email|
      t22_t25_helper(email) do |avg, words_in_subject|
        r[:score] = r[:score].to_f + (words_in_subject.to_f / avg.to_f)
      end
    end
    results
  end

  def self.t25(results)
    each_result(results) do |r, email|
      t22_t25_helper(email) do |avg, words_in_subject|
        r[:score] = r[:score].to_f - (words_in_subject.to_f / avg.to_f)
      end
    end
    results
  end
  
  def self.t26(results)
    each_result(results) do |r, email|
      next unless (9..17).cover?(email.date_time.hour)
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t27(results)
    each_result(results) do |r, email|
      next if (9..17).cover?(email.date_time.hour)
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t28(results)
    each_result(results) do |r, email|
      next unless email.sent?
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t29(results)
    each_result(results) do |r, email|
      next unless email.received?
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t30(results)
    each_result(results) do |r, email|
      next unless email.is_a_reply?
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t31(results)
    each_result(results) do |r, email|
      next if email.is_a_reply?
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t32(results)
    each_result(results) do |r, email|
      next unless email.is_a_forward?
      r[:score] = r[:score].to_f + 1.0
    end
    results
  end
  
  def self.t33(results)
    each_result(results) do |r, email|
      next if email.is_a_forward?
      r[:score] = r[:score].to_f + 1.0
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
  
  def self.t10_t13_helper(email, &block)
    avg = BytesInBody.find_by_mailbox(email.mailbox).average
    block.call(avg)
  end
  
  def self.t14_t17_helper(email, &block)
    avg = WordsInBody.find_by_mailbox(email.mailbox).average
    words_in_body = email.words_in_body
    block.call(avg, words_in_body)
  end
  
  def self.t18_t21_helper(email, &block)
    avg = BytesInSubject.find_by_mailbox(email.mailbox).average
    bytes_in_subject = email.bytes_in_subject
    block.call(avg, bytes_in_subject)
  end
  
  def self.t22_t25_helper(email, &block)
    avg = WordsInSubject.find_by_mailbox(email.mailbox).average
    words_in_subject = email.words_in_subject
    block.call(avg, words_in_subject)
  end

end
