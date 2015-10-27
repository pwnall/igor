# == Schema Information
#
# Table name: assignments
#
#  id                :integer          not null, primary key
#  course_id         :integer          not null
#  author_id         :integer          not null
#  name              :string(64)       not null
#  published_at      :datetime
#  grades_published  :boolean          not null
#  weight            :decimal(16, 8)   not null
#  team_partition_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

# A piece of work that students have to complete.
#
# Examples: problem set, project, exam.
class Assignment < ActiveRecord::Base
  # The course that this assignment is a part of.
  belongs_to :course, inverse_of: :assignments
  validates :course, presence: true

  # The user-visible assignment name (e.g., "PSet 1").
  validates :name, length: 1..64, uniqueness: { scope: :course },
                   presence: true

  # The user that will be reported as the assignment's author.
  belongs_to :author, class_name: 'User'
  validates :author, presence: true

  # True if the given user is allowed to see this assignment.
  def can_read?(user)
     published? || can_edit?(user)
  end

  # True if the given user is allowed to submit solutions for this assignment.
  def can_submit?(user)
    (published? && !deadline_passed_for?(user)) || can_edit?(user)
  end

  # True if the given user is allowed to change this assignment.
  def can_edit?(user)
    course.can_edit? user
  end
end

# :nodoc: homework submission feature.
class Assignment
  include HasDeadline

  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, dependent: :destroy, inverse_of: :assignment
  validates_associated :deliverables
  accepts_nested_attributes_for :deliverables, allow_destroy: true,
                                               reject_if: :all_blank

  # All students' submissions for this assignment.
  has_many :submissions, through: :deliverables, inverse_of: :assignment

  # Deliverables that the given user can see (not necessarily submit files for).
  def deliverables_for(user)
    (published? || can_edit?(user)) ? deliverables : deliverables.none
  end

  # Number of submissions that will be received for this assignment.
  #
  # The estimation is based on the number of students in the class.
  def expected_submissions
    deliverables.count * course.students.count
  end
end

# :nodoc: grade collection and publishing feature.
class Assignment
  # The assignment's weight when computing total class scores.
  #
  # The weight is relative to the weights of all the other assignments in this
  # course. So an assignment of weight 3 is weighed 1.5x as heavily as an
  # assignment of weight 2. If no other assignments are added, the latter
  # assignment will account for 40% of the student's grade.
  validates :weight, numericality: { greater_than_or_equal_to: 0 }

  # The default time when the deliverables will be released to students.
  validates :published_at, timeliness: { before: :due_at, allow_nil: true }

  # Nullify :published_at if the author did not decide a release date.
  def act_on_reset_published_at
    if @reset_publish_date
      self.published_at = nil
      @reset_publish_date = nil
    end
  end
  private :act_on_reset_published_at
  before_validation :act_on_reset_published_at

  # If true, students can see their grades on the assignment.
  validates :grades_published, inclusion: { in: [true, false],
                                            allow_nil: false }
  validates_each :grades_published do |record, attr, value|
    if value && !record.published?
      record.errors.add attr, "must be false if the release date hasn't passed"
    end
  end

  # The metrics that the students are graded on for this assignment.
  has_many :metrics, class_name: 'AssignmentMetric', dependent: :destroy,
                     inverse_of: :assignment
  validates_associated :metrics
  accepts_nested_attributes_for :metrics, allow_destroy: true,
                                          reject_if: :all_blank

  # All students' grades for this assignment.
  has_many :grades, through: :metrics

  # Resources relevant to this assignment, which students can download.
  has_many :files, inverse_of: :assignment, class_name: 'AssignmentFile',
      dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true

  # True if the publish date was omitted (reset to nil) (virtual attribute).
  def reset_publish_date
    published_at.nil?
  end

  # Store the user's decision to set or omit (reset) the publish date.
  #
  # @param [String] state '0' if setting a date, '1' if omitting
  def reset_publish_date=(state)
    @reset_publish_date = state.to_i != 0
  end

  # True if the deliverables have been released to students.
  def published?
    !!published_at && (published_at < Time.current)
  end

  # The resource files for this assignment that are visible to the given user.
  def files_for(user)
    files.select { |f| f.can_read? user }
  end

  # Number of submissions that will be received for this assignment.
  #
  # The estimation is based on the number of students in the class.
  def expected_grades
    metrics.count * course.students.count
  end
end

# :nodoc: score calculations.
class Assignment
  include AverageScore

  # The maximum score that a student can obtain on this assignment.
  #
  # This number is the sum of all the metrics' weighted maximum scores, or nil
  # if this assignment has no metrics.
  #
  # This same method is defined for AssignmentMetric so that the method can be
  # called on either an Assignment or AssignmentMetric instance.
  def max_score
    return nil if metrics.empty?
    metrics.sum(&:weighted_max_score)
  end

  # The average of all the students' scores for this assignment.
  #
  # The returned score is weighted, and should be divided by a weighted max
  # score to calculate a percentage. Ungraded metrics are assigned a score of 0.
  # Returns nil if this assignment has no metrics. Students who have not
  # received a grade for any of this assignment's metrics are ignored.
  #
  # This same method is defined for AssignmentMetric so that the method can be
  # called on either an Assignment or AssignmentMetric instance.
  def average_score
    return nil if metrics.empty?
    totals = grades.includes(:subject).group_by(&:subject).map { |_, grades|
      grades.sum(&:weighted_score) }
    return 0 if totals.empty?
    totals.sum.to_f / totals.length
  end

  # The weighted average score for this assignment given a recitation.
  #
  # This is the sum of all the weighted metrics' recitation averaged scores. It
  # should be divided by a weighted max score to calculate a percentage.
  def recitation_score(recitation)
    metrics.sum { |m| m.grade_for_recitation(recitation) * m.weight }
  end
end

# :nodoc: lifecycle
class Assignment
  # This assignment's position in the assignment lifecycle.
  #
  # :draft -- under construction, not available to students
  # :open -- the assignment accepts submissions from students
  # :grading -- the assignment doesn't accept submissions, grades are not ready
  # :graded -- grades have been released to students
  def ui_state_for(user)
    if grades_published?
      :graded
    elsif published?
      if deadline_passed_for? user
        :grading
      else
        :open
      end
    else
      :draft
    end
  end
end

# :nodoc: team integration.
class Assignment
  # The partition of teams used for this assignment.
  belongs_to :team_partition, inverse_of: :assignments

  # The object to be set as the subject on this assignment's grades for a user.
  def grade_subject_for(user)
    team_partition.nil? ? user : team_partition.team_for_user(user)
  end
end
