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

    # The user (on the course staff) who last edited this grade or comment.
    belongs_to :grader, class_name: 'User'
    validates :grader, presence: true

    # The user or team receiving this grade or comment.
    belongs_to :subject, polymorphic: true
    validates_each :subject do |record, attr, value|
      if value.nil?
        record.errors.add attr, 'is not present'
      elsif !value.enrolled_in_course?(record.course)
        # NOTE: Auto-graders are allowed to assign grades to course staff, so
        #       the staff can test their analyzers.
        unless record.grader && record.grader.robot?
          record.errors.add attr, 'is not connected to the course'
        end
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
      User.with_param(subject_id).first
    when 'Team'
      Team.find_by id: subject_id
    else
      nil
    end
  end
end
