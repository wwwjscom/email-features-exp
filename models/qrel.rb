class Qrel < ActiveRecord::Base

  def self.evaluate(results, top_k)
    topic = results.first[:topic]
    rel_docs  = Qrel.where(:topic => topic).where(:rel => 1).count
    #nrel_docs = Qrel.where(:topic => topic).where(:rel => 0).count
    #wtf_docs  = Qrel.where(:topic => topic).where(:rel => -1).count

    docs = []
    (0..top_k).each { |i| docs << results[i][:doc] }
    rel_found = Qrel.where(:topic => topic).where(:doc => docs).where(:rel => 1).count

    r = (rel_found/rel_docs.to_f)
    p = (rel_found/top_k.to_f)
    f = 2*((p*r)/(p+r))
    log "Recall: %0.03f" % r
    log "Precision: %0.03f" % p
    log "F1: %0.03f" % f
  end
end
