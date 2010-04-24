# An item that shows up in the Deadlines widget.
class Deadline < ActiveModel::Base
  # The date when the deadline is due.
  attr_accessor :date
  # Short description for the deadline.
  attr_accessor :headline
  # An action that can lead to completing the deadline.
  attr_accessor :link
  # True if the deadline should show up as completed / fulfilled.
  attr_accessor :done
  alias_method :done?, :done
  # The object that triggered the deadline.
  attr_accessor :source

  # The deadlines that are relevant to a user.
  #
  # Returns an array of Deadline objects sorted in order of relevance.
  def self.for(user = nil, options = {})
    deadlines = []
    
    Assignment.includes(:deliverables, :feedback_question_set).
               order('deadline DESC').each do |assignment|
      include_feedback = false
      assignment.deliverables.each do |deliverable|
        d = Deadline.new :date => assignment.deadline, :done => false,
                         :headline =>
                             "#{deliverable.name} for #{assignment.name}",
                         :link => deliverable, :source => assignment
        if deliverable.submission_for(user)
          d.done = true
          include_feedback = true
        end
      end
    
      deadlines << Deadline.new :date => d.deadline,
                                :headline => d.name,
    end
               map { |a| a.feedback_question_set ? a.deliverables.all + [a] : a.deliverables.all }.
                           flatten    
  end
end
