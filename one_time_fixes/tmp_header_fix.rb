require 'rubygems'
require 'active_record'

# Recirsively searches for where the header object
# where the header field started.  Since line wraps 
# can cause a single header field to spill onto 
# multiple lines.
#
# Once found, it returns the header object 
def find_line_where_header_value_started(header)
  prev_header = Header.find(header.id-1)
  if prev_header.line_wrap == 1
    find_line_where_header_value_started(prev_header)
  else
    return prev_header
  end
end

def connect_to_db
  conn = ActiveRecord::Base.establish_connection(
    :adapter => "mysql2",
    :host => "localhost",
    :database => 'enron_emails',
    :username => 'root',
    :password => ''
  )
end

class Header < ActiveRecord::Base
  self.table_name = "headers"
  belongs_to :email
end

connect_to_db

Header.find_each do |header|
  original_text = header.original_text
  if original_text[/^(Cc|Date|Subject|X-SDOC|X-ZLID|To|From|Attachment): ?/i]
    label, value = header.original_text.split(": ",2)
    header.label = label
    header.value = value
  else
    # Line is a wrap form the previous one
    starting_header = find_line_where_header_value_started(header)
    starting_header.value = starting_header.value + " " + header.original_text.strip
    starting_header.save

    header.label = nil
    header.value = nil
    header.line_wrap = true
  end
  header.save
end

