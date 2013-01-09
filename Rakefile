require 'rubygems'
require 'rake'
require 'tire'
require_relative 'configs/db'
DB.connect

# blank
namespace :features do
  desc "Recalculate the Volume By Day"
  task :volume_by_day do
    require_relative "features/email_volume_by_day"
  end

  desc "Recalculate the Volume by Hour"
  task :volume_by_hour do
    require_relative "features/email_volume_by_hour"
  end
end
