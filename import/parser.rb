require 'rubygems'
require 'active_record'
require_relative '../models/header'
require_relative '../models/email'
require_relative '../configs/db'

class String
  def is_fake_file
    (self[0] == '.' || self == "parser.rb")
  end

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

  def parse_header_line
    l = self
    l.chomp!
    header = Header.create(:original_text => l)

    if l[/^(Cc|Date|Subject|X-SDOC|X-ZLID|To|From|Attachment): ?/i]
      label, value = l.split(": ",2)
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
    header
  end

  def to_email
    lines = []
    File.open(self) do |f|
      lines = f.lines.to_a
    end

    return if lines == nil || lines[0] == nil
    return unless lines[0][/^Date: .+\(PST\)\r\n$/] # File is an attachment not an email
    e = Email.new
    e.file_name = self
    #e.mailbox = Dir.pwd[/edrm-enron-v2_.+\.zip/][14..-9]
    e.mailbox = Dir.pwd[/edrm-enron-v2_.+\.zip/][14..-1].split("_xml")[0]

    # Construct the header
    while ((l = lines.shift) != "\r\n")
      break unless l
      e.header << l.parse_header_line
    end

    # Construct the body
    e.body = ""
    inside_bs_tag = false
    while ((l = lines.shift) != nil)
      next unless l
      if l == "***********\r\n"
        inside_bs_tag = (inside_bs_tag) ? false : true
        next
      end
      next if inside_bs_tag

      if l[/^Attachment: .+ type=.+/]
        e.header << l.parse_header_line
      else
        e.body = e.body + l
      end
    end

    begin
      e.save
    rescue
      puts "[!] Error processing #{self}"
      DB.connect
    end
  end
end

class TRECParser

  IGNORE_DIRECTORIES = %w{code}
  # Returns an array of email file names inside the dir (recursivelly)
  def self.find_emails_in_dir(dir)
    Dir.chdir(dir)

    Dir.entries('.').each do |e|
      next if e.is_fake_file
      next if IGNORE_DIRECTORIES.include?(e)

      if File.directory?(e)
        puts "[-] Inspecting: '#{e}'"
        find_emails_in_dir(e)
        Dir.chdir('..')
        next
      else
        e.to_email
      end
    end
  end

  def self.run(base_dir)
    puts "[-] Deleting old entries"
    `mysql -u root enron_emails -e 'delete from headers;'`
    `mysql -u root enron_emails -e 'delete from emails;'`
    `mysql -u root enron_emails -e 'ALTER TABLE enron_emails.emails AUTO_INCREMENT=1;'`
    `mysql -u root enron_emails -e 'ALTER TABLE enron_emails.headers AUTO_INCREMENT=1;'`
    puts "[-] done"

    DB.connect
    find_emails_in_dir(base_dir)
  end


end
