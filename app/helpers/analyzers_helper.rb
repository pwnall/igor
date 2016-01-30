module AnalyzersHelper
  # The placeholder to use for the given deliverable and form field.
  def deliverable_field_placeholder(deliverable, field)
    fields = case deliverable.analyzer
    when ProcAnalyzer
      { name: 'PDF Write-up',
        description: 'Please upload your write-up, in PDF format.' }
    when DockerAnalyzer
      { name: 'Fibonacci Code',
        description: 'Please upload your modified fib.py.' }
    else
      raise "Un-implemented analyzer type: #{deliverable.analyzer.inspect}"
    end
    fields[field]
  end

  # The name of the partial with fields for the given deliverable's analyzer.
  def analyzer_partial_for_deliverable(deliverable)
    case deliverable.analyzer
    when ProcAnalyzer
      'proc_analyzers/fields'
    when DockerAnalyzer
      'docker_analyzers/fields'
    else
      raise "Un-implemented analyzer type: #{deliverable.analyzer.inspect}"
    end
  end

  # The Analyzer types as option tags.
  def analyzer_types_for_select
    options_for_select({
      'Built-in Analyzer' => 'ProcAnalyzer',
      'Docker Analyzer' => 'DockerAnalyzer',
    })
  end

  # Array of ProcAnalyzer message names suitable for use in a select_tag helper.
  def proc_analyzer_messages_for_select
    [
      ['PDF Analyzer', 'analyze_pdf'],
    ]
  end
end
