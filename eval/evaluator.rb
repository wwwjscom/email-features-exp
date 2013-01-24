require_relative "../models/qrel"
class Evaluator

#  def self.eval(dir_name)
#    first = true
#    Dir.entries('./results').each do |e|
#      next unless e[0] == "t"
#      log "Checking out #{e}", :debug
#      if first
#        `mkdir results/#{dir_name}`
#        first = false
#      end
#
#      lines = []
#      File.open("./results/#{e}").each_line do |l|
#        topic, d, doc, rank, score, email_id = l.chomp.split(" ")
#        lines << { :topic => topic,
#                    :doc => doc,
#                    :rank => rank,
#                    :score => score,
#                    :email_id => email_id}
#      end
#
#      log "-----Top 10"
#      Qrel.evaluate(lines, 10)
#      log "-----Top 20"
#      Qrel.evaluate(lines, 20)
#      log "-----Top 50"
#      Qrel.evaluate(lines, 50)
#      log "-----Top 100"
#      Qrel.evaluate(lines, 100)
#
#      `mkdir results/#{dir_name}/#{e}`
#      `mv results/#{e}* results/#{dir_name}/#{e}`
#    end
#  end

  def self.eval(dir_name)
    first = true
    Dir.entries('./results').each do |e|
      next unless e[0] == "t"
      log "Checking out #{e}", :debug
      if first
        `mkdir results/#{dir_name}`
        first = false
      end
      `tar -czvf ./results/#{e}.gz ./results/#{e}`
      log "Done playing with #{e}", :debug
      `./eval/dolegal10eval ./eval/qrels.t10legallearn ./results/#{e}`
      `mkdir results/#{dir_name}/#{e}`
      `mv results/#{e}* results/#{dir_name}/#{e}`
    end
  end
end
