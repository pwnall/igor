#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

course = Course.main

exam = Assignment.create! :course => course, :name => "Exam 1",
      :deadline => Time.now - 2.day
[2, 20, 18, 20, 20, 20, 20].each_with_index do |points, i|
  metric =  AssignmentMetric.create! :assignment => exam, :name => "Problem #{i + 1}",
      :published => false, :weight => 1.0, :max_score => points
end
