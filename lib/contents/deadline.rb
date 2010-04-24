# :nodoc: namespace
module Contents


# An item that shows up in the Deadlines widget.
class Deadline
  # The date when the deadline is due.
  attr_accessor :date
  # Short description for the deadline.
  attr_accessor :headline
  # An action that can lead to completing the deadline.
  attr_accessor :link
  # True if the deadline's action can still be done.
  attr_accessor :active
  alias_method :active?, :active
  # True if the deadline should show up as completed / fulfilled.
  attr_accessor :done
  alias_method :done?, :done
  # The object that triggered the deadline.
  attr_accessor :source
  
  # True if the deadline passed and the user hasn't fulfilled it.
  def overdue?
    !done? and date < Time.now
  end

  # Returns :pending, :done, :overdue, or :missed.
  def state
    if done?
      :done
    elsif overdue?
      active? ? :overdue : :missed
    else
      :missed
    end
  end

  # The deadlines that are relevant to a user.
  #
  # Returns an array of Deadline objects sorted in order of relevance.
  def self.for(user = nil, options = {})
    if user
      feedbacks_by_aid = user.assignment_feedbacks.index_by(&:assignment_id)
    else
      feedbacks_by_aid = []
    end
    
    deadlines = []    
    Assignment.includes(:deliverables, :feedback_question_set).
               order('deadline DESC').each do |assignment|
      include_feedback = user ? false : true
      assignment.deliverables.each do |deliverable|
        d = Deadline.new :date => assignment.deadline, :done => false,
                         :active => true, :headline =>
                             "#{deliverable.name} for #{assignment.name}",
                         :link => deliverable, :source => assignment
        if user and deliverable.submission_for_user(user)
          # TODO(costan): make deadline inactive if we posted grades or admin disabled submissions
          d.done = true
          include_feedback = true
        end
        deadlines << d
      end
    
      if include_feedback and assignment.feedback_question_set
        d = Deadline.new :date => assignment.deadline, :done => false,         
                         :headline => "Feedback for #{assignment.name}",
                         :link => assignment, :source => assignment,
                         :active => assignment.accepts_feedback
        d.done = true if feedbacks_by_aid[assignment.id]
        deadlines << d
      end
    end
    deadlines
  end
  
  # Creates a new deadline with the given attributes.
  def initialize(attributes = {})
    attributes.each { |name, value| send :"#{name}=", value }
  end
end  # class Contents::Deadline

end  # namespace Contents
