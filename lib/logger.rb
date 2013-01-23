module Kernel
  def log(string, level = :info)
    mark = case level
           when :info then "-"
           when :warn then "!"
           when :debug then "_"
           when :error then "^"
           end
    puts "[#{mark}] #{string}"
  end
end
