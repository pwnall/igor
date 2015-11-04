# An item that shows up in the News feed.
class FeedItem
  class <<self
    include ActionView::Helpers::NumberHelper
    include AnalysesHelper
  end

  # The time the item was posted. Usually items will be sorted by time.
  attr_accessor :time
  # The User who posted this item.
  attr_accessor :author
  # A (hopefully) short summary of the item.
  attr_accessor :headline
  # The main information in the item.
  attr_accessor :contents
  # Array of actions for interacting with the item.
  #
  # Each action is a pair which should respond to the following methods:
  #     first:: the user-visible name for the action
  #     last::  the link target for the action
  attr_accessor :actions
  # The type of information conveyed by this item.
  #
  # This attribute should be named :type, but Rails uses :type for Single-Table
  # Inheritance, so we had to avoid that name.
  attr_accessor :flavor
  # Follow-ups to this item.
  attr_accessor :replies

  # The items that are readable by a user.
  #
  # Returns an array of FeedItems objects sorted in order of relevance.
  def self.for(user, options = {})
    items = []

    if user
      add_survey_responses items, user, options
      add_submissions items, user, options
    end
    add_grades items, user, options
    add_deliverables items, user, options
    add_announcements items, user, options

    items.sort_by(&:time).reverse
  end

  # Generates feed items for the user's submitted surveys.
  def self.add_survey_responses(items, user, options)
    user.survey_responses.each do |response|
      item = FeedItem.new time: response.updated_at,
          author: response.user, flavor: :survey_answer,
          headline: "responded to a survey: #{response.survey.name}",
          contents: '',
          actions: [['Edit', [:survey_path, response.survey,
                              { course_id: response.course }]]],
          replies: []
      items << item
    end
  end

  # Generates feed items for the submissions that the user can see.
  def self.add_submissions(items, user, options)
    user.connected_submissions.each do |submission|
      item = FeedItem.new time: submission.updated_at,
          author: submission.subject, flavor: :submission,
          headline: "submitted a #{submission.deliverable.name} for " +
                    submission.deliverable.assignment.name,
          contents: number_to_human_size(submission.db_file.f.size) +
                    " #{submission.db_file.f_content_type} file",
          actions: [
            ['Download', [:file_submission_path, submission,
                          { course_id: submission.course }]]
          ],
          replies: []
      items << item
      if analysis = submission.analysis
        reply = FeedItem.new time: analysis.updated_at,
            author: User.robot, flavor: :announcement,
            contents: analysis_status_text(submission.analysis),
            actions: [
              ['Details', [:analysis_path, analysis,
                           { course_id: analysis.course }]]
            ],
            replies: []
        item.replies << reply
      end
    end
  end

  # Generates feed items for the published grades.
  def self.add_grades(items, user, options)
    Assignment.where(grades_published: true).includes(:metrics).
               each do |assignment|
      next unless last_metric = assignment.metrics.sort_by(&:updated_at).last
      next unless last_grade = last_metric.grades.sort_by(&:updated_at).last

      item = FeedItem.new time: (last_grade || last_metric).updated_at,
          author: assignment.author, flavor: :grade,
          headline: "released the grades for #{assignment.name}",
          contents: '',
          actions: [['View', [:grades_path,
                              { course_id: assignment.course }]]],
          replies: []
      items << item
    end
  end

  # Generates feed items for the published deliverables.
  def self.add_deliverables(items, user, options)
    Deliverable.includes(:assignment).each do |deliverable|
      next unless deliverable.can_read?(user)

      assignment = deliverable.assignment
      with_teammates = assignment.team_partition_id ? 'and your teammates ' : ''
      item = FeedItem.new time: deliverable.updated_at,
          author: assignment.author, flavor: :deliverable,
          headline: "opened up " + "#{assignment.name}'s #{deliverable.name} " +
              "for submissions",
          contents: deliverable.description,
          actions: [['Submit', [:assignment_path, assignment,
                                { course_id: deliverable.course }]]],
          replies: []
      items << item

      if assignment.deadline_passed_for? user
        reply = FeedItem.new time: assignment.due_at_for(user),
            author: User.robot, flavor: :announcement,
            contents: "The deadline has passed.",
            actions: [], replies: []
        item.replies << reply
      end
    end
  end

  # Generates feed items for the published announcements.
  def self.add_announcements(items, user, options)
    Announcement.all.each do |announcement|
      # TODO(costan): distinguish between open announcements,
      #               semi-open (login required), and admin-only; right now,
      #               the default is semi-open, so we can post sensitive info
      next unless user or announcement.open_to_visitors?

      item = FeedItem.new time: announcement.created_at,
          author: announcement.author, flavor: :announcement,
          headline: announcement.headline.html_safe,
          contents: announcement.contents.html_safe,
          actions: [],
          replies: []

      if announcement.can_edit? user
        item.actions = [
          ['Edit', [:edit_announcement_path, announcement,
                    { course_id: announcement.course }]],
          ['Delete', [:announcement_path, announcement,
                      { course_id: announcement.course }],
                     { confirm: 'Are you sure?', method: :delete }]
        ]
      end
      items << item
    end
  end

  # Creates a new feed item with the given attributes.
  def initialize(attributes = {})
    attributes.each { |name, value| send :"#{name}=", value }
  end
end  # class Contents::FeedItem
