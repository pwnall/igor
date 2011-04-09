# :nodoc: namespace
module Contents


# An item that shows up in the Deadlines widget.
class Deadline
  # The date when the deadline is due.
  attr_accessor :due
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
    !done? and due < Time.now
  end

  # Returns :pending, :done, :overdue, or :missed.
  def state
    if done?
      :done
    elsif overdue?
      active? ? :overdue : :missed
    else
      :pending
    end
  end

  # The deadlines that are relevant to a user.
  #
  # Returns an array of Deadline objects sorted in order of relevance.
  def self.for(user = nil, options = {})
    if user
      answers_by_aid = user.survey_answers.index_by(&:assignment_id)
    else
      answers_by_aid = []
    end
    
    deadlines = []
    Assignment.includes(:deliverables, :feedback_survey).
               order('deadline DESC').each do |assignment|
      include_feedback = user ? false : true
      assignment.deliverables.each do |deliverable|
        next unless deliverable.visible_for_user?(nil)
        d = Deadline.new :due => assignment.deadline, :done => false,
                         :active => true, :source => assignment,
                         :headline =>
                             "#{deliverable.name} for #{assignment.name}",                         
                         :link => [
                            [:new_submission_path,
                             {:submission => {:deliverable_id => deliverable}}],
                            {:remote => true}
                         ]

        if user and deliverable.submission_for_user(user)
          # TODO(costan): make deadline inactive if we posted grades or admin disabled submissions
          d.done = true
          include_feedback = true
        end
        deadlines << d
      end
    
      if include_feedback and assignment.feedback_survey
        d = Deadline.new :due => assignment.deadline, :done => false,         
                         :headline => "Feedback survey for #{assignment.name}",
                         :link => [[:new_survey_answer_path,
                                    {:survey_answer => {:assignment_id =>
                                                          assignment.id } }],
                                   {:remote => true}],
                         :source => assignment,
                         :active => assignment.accepts_feedback
        d.done = true if answers_by_aid[assignment.id]
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
