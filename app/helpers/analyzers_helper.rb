module AnalyzersHelper
  # Conjures up an analyzer of the desired type for the deliverable.
  #
  # If the deliverable has an analyzer, and the analyzer has the right type,
  # that analyzer is returned. Otherwise, a new Analyzer of the right type is
  # created and returned.
  def analyzer_for(deliverable, klass = ProcAnalyzer)
    analyzer = deliverable.analyzer
    analyzer = klass.new unless analyzer.kind_of?(klass)
    analyzer
  end

  # Array of Analyzer types suitable for use in a select_tag helper.
  def analyzer_types_for_select
    [
      ['Built-in Analyzer', 'ProcAnalyzer'],
      ['Docker Analyzer', 'DockerAnalyzer'],
      ['Script Analyzer', 'ScriptAnalyzer'],
    ]
  end

  # Array of ProcAnalyzer message names suitable for use in a select_tag helper.
  def proc_analyzer_messages_for_select
    [
      ['PDF Analyzer', 'analyze_pdf'],
    ]
  end
end
