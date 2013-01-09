require 'rubygems'
require 'tire'
require 'yajl'
require_relative 'db'
require_relative 'email'
require_relative 'header'

DB.connect
Email.import
Header.import
