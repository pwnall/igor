module DeliverablesHelper
  # Conjures up an analyzer of the desired type for the deliverable.
  #
  # If the deliverable has an analyzer, and the analyzer has the right type,
  # that analyzer is returned. Otherwise, a new Analyzer of the right type is
  # created and returned. 
  def analyzer_for(deliverable, klass = ProcAnalyzer)
    if deliverable.analyzer && deliverable.analyzer.kind_of?(klass)
      deliverable.analyzer
    else
      klass.new :deliverable => deliverable
    end
  end
end
