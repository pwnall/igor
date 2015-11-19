# An item that shows up in the Deadlines widget.
class ActionItem
  # The assignment or survey that this action item describes.
  attr_accessor :subject
  # The date when the action item is due.
  attr_accessor :due_at
  # Short description for the action item.
  attr_accessor :description
  # An action that can lead to completing the action item.
  attr_accessor :link  # UI thing
  # The state of the user's progress on the task (:incomplete, :ok, :rejected).
  #
  # :incomplete => The user has not uploaded a submission, or the submission
  #     requires analysis and the analyzer has not finished running.
  # :ok => The user has uploaded a submission, which passed any analysis.
  # :rejected => The user's submission was rejected by the analyzer. (Not
  #     relevant for Surveys.)
  attr_accessor :state

  # Creates a new action item for the given user and task.
  def initialize(user, task)
    self.subject = task
    self.due_at = task.due_at_for user
  end

  # The action items in a given course that are relevant to a given user.
  #
  # @param [User] user the student who can complete these tasks
  # @param [Course] course the current course, if any
  # @return [Array<ActionItem>] ActionItems, sorted in order of due date.
  def self.for(user, course)
    items = []
    tasks_for(user, course).each do |task|
      case task
      when Assignment
        task.deliverables.sort_by(&:name).each do |deliverable|
          item = ActionItem.new user, task
          item.description = deliverable.name
          item.link = [:deliverable_panel_path, deliverable]
          item.state = analysis_state_for user, deliverable
          items << item
        end
      when Survey
        item = ActionItem.new user, task
        item.description = task.name
        item.link = [:survey_path, task, { course_id: task.course }]
        item.state = task.answered_by?(user) ? :ok : :incomplete
        items << item
      else
        raise "Un-implemented subject type: #{subject.inspect}"
      end
    end
    items
  end

  # The courses with actionable tasks for the given user.
  #
  # For site admins, all courses are relevant. For all other users, include the
  # courses in which they have any role i.e., student, grader, or instructor
  #
  # @param [User] user the user who can complete the task
  # @return [Array<Course>] an array of the courses relevant to the user
  def self.courses_for(user)
    return [] unless user

    filtered_courses = (user.employed_courses + user.registered_courses).uniq
    user.admin? ? Course.all : filtered_courses
  end

  # The given course's assignments/surveys that the given user can complete.
  #
  # The tasks are ordered first by due date for the given user (soonest to
  # latest), then by alphabetical order of the name.
  #
  # If the course is nil, use the set of courses that is most relevant to the
  # given user. I.e., all courses for admins, courses taken/graded/taught for
  # students and staff members.
  #
  # @param [User] user the user who can complete the tasks
  # @param [Course] course a course by which to filter tasks
  # @return [Array<Assignment|Survey>] an array of actionable tasks, ordered by
  #   due date and name
  def self.tasks_for(user, course)
    courses = course ? [course] : courses_for(user)
    tasks = courses.map { |c| c.upcoming_tasks_for user }.flatten
    tasks.sort_by { |t| [t.due_at_for(user), t.name] }
  end

  # The given user's progress made on the given deliverable.
  #
  # @param [User] user the user who uploaded the submission
  # @param [Deliverable] deliverable the deliverable that the submission is for
  # @return [Symbol] the state to display for the ActionItem (:incomplete,
  #   :ok, or :rejected)
  def self.analysis_state_for(user, deliverable)
    submission = deliverable.submission_for_grading(user)
    return :incomplete unless submission

    analysis = submission.analysis
    if !analysis || analysis.status_will_change?
      :incomplete
    elsif analysis.submission_ok?
      :ok
    elsif analysis.submission_rejected?
      :rejected
    end
  end
end
