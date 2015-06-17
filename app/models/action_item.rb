# An item that shows up in the Deadlines widget.
class ActionItem
  # The date when the action item is due.
  attr_accessor :due_at
  # Short description for the action item.
  attr_accessor :description
  # An action that can lead to completing the action item.
  attr_accessor :link  # UI thing
  # True if the action item can still be done.
  attr_accessor :active
  alias_method :active?, :active
  # True if the action item should indicate a rejected submission.
  attr_accessor :rejected
  alias_method :rejected?, :rejected
  # True if the action item status is expected to change soon.
  attr_accessor :changing
  alias_method :changing?, :changing
  # True if the action item should show up as completed / fulfilled.
  attr_accessor :done
  alias_method :done?, :done
  # The assignment or survey that this action item describes.
  attr_accessor :subject

  # True if the deadline passed and the user hasn't fulfilled it.
  def overdue?
    !done? && due_at < Time.now
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

  # Creates a new action item with the given attributes.
  def initialize(attributes = {})
    attributes.each { |name, value| send :"#{name}=", value }
  end

  # The action items that are relevant to a user.
  #
  # TODO(costan): make action item inactive if we posted grades or admin
  #   disabled submissions.
  #
  # Returns an array of ActionItems, sorted in order of due date.
  def self.for(user, options = {})
    items = []
    if user && !user.admin?
      courses = user.courses
    else
      courses = Course.all
    end
    courses.map(&:deadlines).flatten.each do |deadline|
      case deadline.subject
      when Assignment
        next unless deadline.subject.can_read?(user)
        deadline.subject.deliverables_for(user).each do |deliverable|
          item = ActionItem.new default_attrs(deadline)
          item.description = deliverable.name
          item.active = true
          item.link = [[:assignment_path, deadline.subject]]
          if submission = deliverable.submission_for(user)
            item.done = !submission.analysis ||
                        submission.analysis.submission_ok?
          end
          items << item
        end
      when Survey
        item = ActionItem.new default_attrs(deadline)
        item.description = deadline.subject.name
        item.active = deadline.subject.published?
        item.link = [[:new_survey_answer_path, { survey_answer:
                        { survey_id: deadline.subject.to_param } }],
                     { remote: true }]
        item.done = true if deadline.subject.answer_for(user)
        items << item
      else
        raise "Un-implemented subject type: #{subject.inspect}"
      end
    end
    items
  end

  # The ActionItem attributes that are common to both Assignment and Survey.
  #
  # @param [Deadline] deadline the deadline for an assignment or survey
  def self.default_attrs(deadline)
    { subject: deadline.subject, due_at: deadline.due_at, done: false }
  end
  private_class_method :default_attrs
end  # class Contents::Deadline
