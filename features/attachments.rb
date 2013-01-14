require_relative 'feature'

class Attachment < Feature
  self.table_name = "attachments"

  def self.reset
    Attachment.delete_all
    reset_counter(self.table_name)
  end

  def self.recalc
    mailbox_names.each do |mailbox|
      emails_by_mailbox(mailbox) do |email|
        next unless email.has_attachment?
        email.attachments.each { |a| Attachment.create(a) }
      end
    end
  end
end
