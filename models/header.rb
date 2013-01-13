require 'rubygems'
require 'tire'
require 'active_record'
require 'will_paginate'

class Header < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :email_id,           :index    => :not_analyzed
    indexes :original_text,           :index    => :not_analyzed
    indexes :line_wrap,           :index    => :not_analyzed
    indexes :value,         :analyzer => 'snowball'
    indexes :label,       :analyzer => 'keyword'
  end

  self.table_name = "headers"
  belongs_to :email

  def self.paginate(pagination_hash)
    min = ((pagination_hash[:page]-1)*pagination_hash[:per_page])+1
    max = pagination_hash[:page]*pagination_hash[:per_page]
    where("id" => (min..max))
  end

  def self._from(email_id)
    _from = where(:email_id => email_id).where(:label => "From").first
    (_from == nil) ? nil : _from.value
  end

  def self.subject_for(email_id)
    subj = where(:label => "Subject").where(:email_id => email_id).first
    (subj == nil) ? false : subj.value
  end

  def self.date_for(email_id)
    _date = where(:label => "Date").where(:email_id => email_id).first
    (_date == nil) ? false : _date.value
  end

end
