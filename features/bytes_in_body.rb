require_relative 'feature'
require_relative '../lib/enum_stats'

class BytesInBody < Feature
  self.table_name = "bytes_in_body"

  def self.reset
    BytesInBody.delete_all
    reset_counter(self.table_name)
  end

  def self.recalc
    mailbox_names.each do |mailbox|
      max, min, total_emails = 0, 99999999, 0
      bytes_a = []

      emails_by_mailbox(mailbox) do |email|
        next unless email.body

        length = email.body.bytesize
        bytes_a << length

        total_emails += 1
        max = length if length > max
        min = length if length < min
      end

      BytesInBody.create(
        :mailbox => mailbox,
        :total_emails => total_emails,
        :min => min,
        :max => max,
        :average => (bytes_a.empty? ? [0] : bytes_a).average,
        :std_dev => (bytes_a.empty? ? [0] : bytes_a).std_dev
      )
    end
  end
end
