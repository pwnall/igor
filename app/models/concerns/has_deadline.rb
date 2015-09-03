require 'active_support'

# Deadline support for Assignment and Survey.
module HasDeadline
  extend ActiveSupport::Concern

  included do
    # The time when all the requested submissions for this task are due.
    #
    # NOTE: The inverse_of is necessary in order for the Deadline record to
    #   validate the presence of its parent subject record.
    has_one :deadline, as: :subject, dependent: :destroy, inverse_of: :subject
    validates :deadline, presence: true
    accepts_nested_attributes_for :deadline

    # Orders a survey or assignment query by deadline, latest to earliest.
    scope :by_deadline, -> { joins(:deadline).includes(:deadline).
        order('deadlines.due_at DESC').order(:name) }

    # Filter for surveys or assignments whose deadlines have passed.
    scope :past_due, -> { joins(:deadline).includes(:deadline).
        where('deadlines.due_at < ?', Time.current) }

    # The deadline extensions granted for this task.
    has_many :extensions, as: :subject, class_name: 'DeadlineExtension',
        dependent: :destroy, inverse_of: :subject

    # User who have been granted extensions for this task.
    has_many :extension_recipients, through: :extensions, source: :user
  end

  # The date of the deadline (virtual attribute).
  def due_at
    deadline && deadline.due_at
  end

  # Set the date of the deadline (virtual attribute).
  def due_at=(date)
    if deadline
      self.deadline.due_at = date
    else
      self.build_deadline due_at: date, course: course
    end
  end

  # The due date, customized to a specific user.
  #
  # @param [User] user the user to whom this deadline applies
  # @return [ActiveSupport::TimeWithZone] the time when the task is due
  def deadline_for(user)
    extension = extensions.find_by(user: user)
    extension ? extension.due_at : deadline.due_at
  end

  # True if the sumbissions for this assignment/survey should be marked as late.
  def deadline_passed_for?(user)
    deadline_for(user) < Time.current
  end
end
