# An item that shows up in the Deadlines widget.
class Deadline
  # The date when the deadline is due.
  attr_accessor :due
  # Short description for the deadline.
  attr_accessor :description
  # An action that can lead to completing the deadline.
  attr_accessor :link
  # True if the deadline's action can still be done.
  attr_accessor :active
  alias_method :active?, :active
  # True if the deadline should indicate a rejected submission.
  attr_accessor :rejected
  alias_method :rejected?, :rejected
  # True if the deadline status is expected to change soon.
  attr_accessor :changing
  alias_method :changing?, :changing
  # True if the deadline should show up as completed / fulfilled.
  attr_accessor :done
  alias_method :done?, :done
  # The assignment that the deadline is for.
  attr_accessor :assignment

  # True if the deadline passed and the user hasn't fulfilled it.
  def overdue?
    !done? && due < Time.now
  end

  # Returns :pending, :done, :overdue, or :missed.
  def state
    if done?
      :done
    elsif overdue?
      active? ? :overdue : :missed
    elsif changing?
      :changing
    elsif rejected?
      :rejected
    else
      :pending
    end
  end

  # The deadlines that are relevant to a user.
  #
  # Returns an array of Deadline objects sorted in order of relevance.
  def self.for(user, options = {})
    if user
      answers_by_aid = user.survey_answers.index_by(&:assignment_id)
    else
      answers_by_aid = []
    end

    deadlines = []
    Assignment.includes(:deliverables, :feedback_survey).
               by_deadline.each do |assignment|
      next unless assignment.can_read?(user)

      include_feedback = user ? false : true
      assignment.deliverables_for(user).each do |deliverable|
        d = Deadline.new :due => assignment.deadline, :done => false,
                         :active => true, :assignment => assignment,
                         :description => deliverable.name,
                         :link => [
                            [:assignment_path, assignment]
                         ]

        if submission = deliverable.submission_for(user)
          # TODO(costan): make deadline inactive if we posted grades or admin disabled submissions
          d.done = !submission.analysis || submission.analysis.submission_ok?
          d.rejected = submission.analysis &&
                       submission.analysis.submission_rejected?
          d.changing = submission.analysis &&
                       submission.analysis.status_will_change?
          include_feedback = true
        end
        deadlines << d
      end

      if include_feedback and assignment.feedback_survey
        d = Deadline.new :due => assignment.deadline, :done => false,
                         :description => "Feedback survey",
                         :link => [[:new_survey_answer_path,
                                    {:survey_answer => {:assignment_id =>
                                                          assignment.id } }],
                                   {:remote => true}],
                         :assignment => assignment,
                         :active => assignment.feedback_survey.published?
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
