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
    first = where(:email_id => email_id).where(:label => "From").first
    return nil if first == nil
    return (first.value == nil) ? nil : first.value
  end

end
