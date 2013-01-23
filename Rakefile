require 'rubygems'
require 'rake'
require 'tire'
require_relative 'configs/db'
require_relative 'models/email'
require_relative 'lib/logger'
DB.connect

namespace :search do
  desc "Run all searches for the parameterized term."
  task :query_for, [:term]  do |t, args|
    # Clean up any old runs that may be laying around that could cause problems
    `rm ./results/t*`

    topic = "207" # FIXME: This shouldn't be hardcoded

    # Querying Code
    require_relative "querying/search"
    Search.all_tests(args[:term])

    # Evaluator Code
    require 'date'
    require_relative "eval/evaluator"
    dir_name = DateTime.now.strftime("%m-%d-%Y_%H:%M:%S__#{args[:term]}")
    Evaluator.eval(dir_name)

    # Summarize
    require_relative "summarize/summarize"
    path = "./results/#{dir_name}"
    Summarize.new(path,topic).summarize
  end
end

namespace :import do
  desc "Import emails to DB from TREC format"
  task :from_trec do
    require_relative "import/parser"
    TRECParser.run("../")
  end
end

namespace :features do
  desc "Recalculate all features"
  task :all do
    Rake::Task["features:volume_by_day"].execute
    Rake::Task["features:volume_by_hour"].execute
    Rake::Task["features:words_in_subject"].execute
    Rake::Task["features:bytes_in_subject"].execute
    Rake::Task["features:words_in_body"].execute
    Rake::Task["features:bytes_in_body"].execute
    Rake::Task["features:attachments"].execute
  end

  desc "Recalculate attachments"
  task :attachments do
    require_relative "features/attachments"
    Attachment.reset
    Attachment.recalc
  end

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
end
