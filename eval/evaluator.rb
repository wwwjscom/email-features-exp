class Evaluator

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
