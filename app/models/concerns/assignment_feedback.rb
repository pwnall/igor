require 'active_support'

# Common functionality in Grade and GradeComment.
module AssignmentFeedback
  extend ActiveSupport::Concern

  included do
    # The course in which the metric was released.
    #
    # This is redundant, but helps find a student's grades or comments for a
    #     specific course.
    belongs_to :course
    validates_each :course do |record, attr, value|
      if value.nil?
        record.errors.add attr, 'is not present'
      elsif record.metric && record.metric.course != value
        record.errors.add attr, "does not match the metric's course"
      end
    end

    # The metric being graded.
    belongs_to :metric, class_name: 'AssignmentMetric', inverse_of: :grades
    validates :metric, uniqueness: { scope: [:subject_id, :subject_type] },
        permission: { subject: :grader, can: :grade }, presence: true
    def metric=(new_metric)
      self.course = new_metric && new_metric.course
      super
    end

    # The user (on the course staff) who last edited this grade or comment.
    belongs_to :grader, class_name: 'User'
    validates :grader, presence: true

    # The user or team receiving this grade or comment.
    belongs_to :subject, polymorphic: true
    validates_each :subject do |record, attr, value|
      if value.nil?
        record.errors.add attr, 'is not present'
      elsif !value.enrolled_in_course?(record.course)
        record.errors.add attr, 'is not connected to the course'
      end
    end
  end

  # Identify the user or team given the object type and external id.
  #
  # @param [String] subject_type the object type
  # @param [String, Integer] subject_id the user's external id or the team's
  #     id
  # @return [User, Team] the user or team with the given id, or nil if
  #     no such record exists
  def self.find_subject(subject_type, subject_id)
    case subject_type
    when 'User'
      User.find_by_param subject_id
    when 'Team'
      Team.find_by id: subject_id
    else
      nil
    end
  end
end
