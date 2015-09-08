module AnalyzersHelper
  # The placeholder to use for the given deliverable and form field.
  def deliverable_field_placeholder(deliverable, field)
    fields = case deliverable.analyzer
    when ProcAnalyzer
      { name: 'PDF Write-up', ext: 'pdf',
        description: 'Please upload your write-up, in PDF format.' }
    when DockerAnalyzer, ScriptAnalyzer
      { name: 'Fibonacci Code', ext: 'py',
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
    when ScriptAnalyzer
      'script_analyzers/fields'
    else
      raise "Un-implemented analyzer type: #{deliverable.analyzer.inspect}"
    end
  end

  # The Analyzer types as option tags.
  def analyzer_types_for_select
    options_for_select({
      'Built-in Analyzer' => 'ProcAnalyzer',
      'Docker Analyzer' => 'DockerAnalyzer',
      'Script Analyzer' => 'ScriptAnalyzer'
    })
  end

  # Array of ProcAnalyzer message names suitable for use in a select_tag helper.
  def proc_analyzer_messages_for_select
    [
      ['PDF Analyzer', 'analyze_pdf'],
    ]
  end
end
