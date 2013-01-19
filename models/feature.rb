require 'active_record'
require_relative '../models/email'

class Feature < ActiveRecord::Base

  # Returns all the mailbox names in the db
  def self.mailbox_names
    mailbox_names = []
    Email.all_mailbox_names.each do |mailbox|
      mailbox_names << mailbox.mailbox
    end
    return mailbox_names
  end

  # Runs the block on each mailbox supplied
  def self.emails_by_mailbox(mailbox, &block)
    Email.where(:mailbox => mailbox).find_each do |email|
      block.call(email)
    end
  end

  def self.reset_counter(table_name)
    `mysql -u root enron_emails -e "ALTER TABLE enron_emails.#{table_name} AUTO_INCREMENT=1;"`
  end
end
