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
    indexes :body,         :analyzer => 'snowball'
    indexes :mailbox,       :analyzer => 'keyword'
    indexes :filename,       :analyzer => 'keyword'
  end


  self.table_name = "emails"
  has_many :header

  def self.paginate(pagination_hash)
    min = ((pagination_hash[:page]-1)*pagination_hash[:per_page])+1
    max = pagination_hash[:page]*pagination_hash[:per_page]
    where("id" => (min..max))
  end

  # Returns an array of all of the mailbox names
  def self.all_mailbox_names
    self.select("mailbox").group("mailbox")
  end

  # Will return false is date is missing
  def date_time
    (self.date) ? DateTime.parse(self.date) : false
  end

  # Will return false is date is missing
  def date
    _date = self.header.where(:label => "Date").first
    (_date) ? _date.value : false
  end

  def subject
    self.header.where(:label => "Subject")
  end
end
