require 'test_helper'

class AnalyzersHelperTest < ActionView::TestCase
  include AnalyzersHelper

  let(:proc_deliverable) { analyzers(:proc_assessment_writeup).deliverable }
  let(:docker_deliverable) { analyzers(:docker_assessment_code).deliverable }

  describe '#deliverable_field_placeholder' do
    it 'returns the appropriate name placeholder for the analyzer type' do
      assert_match /PDF/, deliverable_field_placeholder(proc_deliverable, :name)
      assert_match /Code/, deliverable_field_placeholder(docker_deliverable,
                                                         :name)
      assert_raises(RuntimeError) do
        deliverable_field_placeholder Deliverable.new, :name
      end
    end

    it 'returns the appropriate extension placeholder for the analyzer type' do
      assert_match /pdf/, deliverable_field_placeholder(proc_deliverable, :ext)
      assert_match /py/, deliverable_field_placeholder(docker_deliverable, :ext)
      assert_raises(RuntimeError) do
        deliverable_field_placeholder Deliverable.new, :ext
      end
    end

    it 'returns the appropriate name placeholder for the analyzer type' do
      assert_match /write-up/, deliverable_field_placeholder(proc_deliverable,
                                                             :description)
      assert_match /fib/, deliverable_field_placeholder(docker_deliverable,
                                                        :description)
      assert_raises(RuntimeError) do
        deliverable_field_placeholder Deliverable.new, :name
      end
    end

    it 'returns nil for fields other than :name, :ext, :description' do
      assert_nil deliverable_field_placeholder(proc_deliverable, :auto_grading)
    end
  end

  describe '#analyzer_partial_for_deliverable' do
    it 'returns the appropriate partial name for the analyzer type' do
      assert_match /proc_analyzers/,
          analyzer_partial_for_deliverable(proc_deliverable)
      assert_match /docker_analyzers/,
          analyzer_partial_for_deliverable(docker_deliverable)
      assert_raises(RuntimeError) do
        analyzer_partial_for_deliverable Deliverable.new
      end
    end
  end

  describe '#analyzer_types_for_select' do
    it 'has an <option> for each type of Analyzer' do
      render text: analyzer_types_for_select
      assert_select 'option[value=ProcAnalyzer]', 'Built-in Analyzer'
      assert_select 'option[value=DockerAnalyzer]', 'Docker Analyzer'
    end
  end

  describe '#proc_analyzer_messages_for_select' do
    it 'returns the appropriate message for the analyzer type' do
      proc_analyzer_messages_for_select.each do |analyzer_option|
        if analyzer_option[0] == 'PDF Analyzer'
          assert_equal 'analyze_pdf', analyzer_option[1]
        end
      end
    end
  end
end
