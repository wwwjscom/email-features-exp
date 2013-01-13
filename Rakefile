require 'rubygems'
require 'rake'
require 'tire'
require_relative 'configs/db'
DB.connect

namespace :import do
  desc "Import emails to DB from TREC format"
  task :from_trec do
    require_relative "import/parser"
    TRECParser.run("../")
  end
end

namespace :features do
  desc "Recalculate the Volume By Day"
  task :volume_by_day do
    require_relative "features/email_volume_by_day"
    VolumeByDay.reset
    VolumeByDay.recalc
  end

  desc "Recalculate the Volume by Hour"
  task :volume_by_hour do
    require_relative "features/email_volume_by_hour"
    VolumeByHour.reset
    VolumeByHour.recalc
  end

  desc "Recalculate the Words in Subjects"
  task :words_in_subject do
    require_relative "features/words_in_subject"
    WordsInSubject.reset
    WordsInSubject.recalc
  end

  desc "Recalculate the Bytes in Subjects"
  task :bytes_in_subject do
    require_relative "features/bytes_in_subject"
    BytesInSubject.reset
    BytesInSubject.recalc
  end

  desc "Recalculate the Bytes in Body"
  task :bytes_in_body do
    require_relative "features/bytes_in_body"
    BytesInBody.reset
    BytesInBody.recalc
  end

  desc "Recalculate the Words in Body"
  task :words_in_body do
    require_relative "features/words_in_body"
    WordsInBody.reset
    WordsInBody.recalc
  end

  desc "Recalculate all features"
  task :all do
    Rake::Task["features:volume_by_day"].execute
    Rake::Task["features:volume_by_hour"].execute
    Rake::Task["features:words_in_subject"].execute
    Rake::Task["features:bytes_in_subject"].execute
    Rake::Task["features:words_in_body"].execute
    Rake::Task["features:bytes_in_body"].execute
  end
end
