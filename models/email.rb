require 'rubygems'
require 'tire'
require 'active_record'
require 'will_paginate'
require 'date'
require_relative 'header'

class Email < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :subject,      :analyzer => 'snowball'
    indexes :body,         :analyzer => 'snowball'
    indexes :attachment,   :analyzer => 'keyword'
    indexes :mailbox,      :index => :not_analyzed
    indexes :file_name,     :index => :not_analyzed
  end

  # Tighter control over the way attributes are indexed.  This
  # control allows for adding subject and attachment to the
  # emails index.
  def to_indexed_json
    { 
      :body => body,
      :subject => subject,
      :attachment => (attachments.first == nil) ? "" : attachments.first[:file_name],
      :file_name => file_name
    }.to_json
  end


  self.table_name = "emails"
  has_many :header
  has_many :attachment

  def self.paginate(pagination_hash)
    min = ((pagination_hash[:page]-1)*pagination_hash[:per_page])+1
    max = pagination_hash[:page]*pagination_hash[:per_page]
    where("id" => (min..max))
  end

  # Returns an array of all of the mailbox names
  def self.all_mailbox_names
    self.select("mailbox").group("mailbox")
  end

  def sent?
    (sent_or_received? == :sent) ? true : false
  end

  def received?
    (sent_or_received? == :received) ? true : false
  end

  # Returns whether the email was sent or received by the
  # mailbox owner.  Can also return nil is the "From" field
  # in the email is not present.
  def sent_or_received?
    last_name, first_initial = mailbox.split("-")
    from = Header._from(id)

    if from == nil
      return nil
    else
      return (from[/#{last_name}.+#{first_initial}/i] != nil || from[/#{first_initial}.+#{last_name}/i] != nil) ? :sent : :received
    end
  end

  # Will return false is date is missing
  def date_time
    (self.date) ? DateTime.parse(self.date) : false
  end

  # Will return false is date is missing
  def date
    Header.date_for(id)
  end

  def subject
    Header.subject_for(id)
  end

  def is_a_reply?
    (subject[/^re: /i]) ? true : false
  end

  def is_a_forward?
    (subject[/^fwd?: /i]) ? true : false
  end

  def has_attachment?
    Header.has_attachment?(id)
  end

  def attachments
    Header.attachments(id)
  end

  def bytes_in_body
    BytesInBody.for(body)
  end

  def words_in_body
    WordsInBody.for(body)
  end

  def bytes_in_subject
    BytesInSubject.for(subject)
  end

  def words_in_subject
    WordsInSubject.for(subject)
  end
end
