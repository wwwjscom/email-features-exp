require 'active_record'

class DB
  def self.connect
    conn = ActiveRecord::Base.establish_connection(
      :adapter => "mysql2",
      :host => "localhost",
      :database => 'enron_emails',
      :username => 'root',
      :password => ''
    )
  end
end
