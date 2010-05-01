# :nodoc: namespace
module Contents


# An item that shows up in the News feed.
class FeedItem
  class <<self
    include ActionView::Helpers::NumberHelper
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
      add_survey_answers items, user, options
      add_submissions items, user, options
    end
    add_grades items, user, options
    add_deliverables items, user, options
    add_announcements items, user, options
    
    items.sort_by(&:time).reverse
  end
  
  # Generates feed items for the user's submitted surveys.
  def self.add_survey_answers(items, user, options)
    user.survey_answers.each do |answer|
      item = FeedItem.new :time => answer.updated_at,
          :author => answer.user, :flavor => :survey_answer,
          :headline => "answered a survey on #{answer.assignment.name}",
          :contents => '',
          :actions => [['Edit', [:edit_survey_answer_path, answer]]],
          :replies => []
      items << item      
    end
  end

  # Generates feed items for the submissions that the user can see.
  def self.add_submissions(items, user, options)
    user.connected_submissions.each do |submission|
      item = FeedItem.new :time => submission.updated_at,
          :author => submission.user, :flavor => :submission,
          :headline => "submitted a #{submission.deliverable.name} for " +
                       submission.deliverable.assignment.name,
          :contents => number_to_human_size(submission.code.size) +
                       " #{submission.code_content_type} file",
          :actions => [
            ['View', [:file_submission_path, submission, {:inline => true}]],
            ['Download', [:file_submission_path, submission, {:inline => false}]]
          ],
          :replies => []
      items << item
      if run_result = submission.run_result
        reply = FeedItem.new :time => run_result.updated_at,
            :author => User.first, :flavor => :announcement,
            :contents => run_result.diagnostic,
            :actions => [
              ['Details', [:url_for, run_result]]
            ],
            :replies => []
        item.replies << reply
      end
    end
  end
  
  # Generates feed items for the published grades.
  def self.add_grades(items, user, options)
    Assignment.includes(:metrics).each do |assignment|
      metrics = assignment.metrics.select { |m| m.visible_for_user?(user) }
      next if metrics.empty?
      
      last_grade = metrics.sort_by(&:updated_at).last.grades.
                           sort_by(&:updated_at).last
      item = FeedItem.new :time => last_grade.updated_at,
           :author => last_grade.grader, :flavor => :grade,
           :headline => "released the grades for #{assignment.name}",
           :contents => '',
           :actions => [
             ['View', [:reveal_mine_grades_path]]
           ],
           :replies => []
      items << item
    end
  end
  
  # Generates feed items for the published deliverables.   
  def self.add_deliverables(items, user, options)
    Deliverable.includes(:assignment).each do |deliverable|
      next unless deliverable.visible_for_user?(user)
      
      # TODO(costan): get authors on deliverables
      with_teammates = deliverable.assignment.team_partition_id ?
                       'and your teammates ' : ''
      item = FeedItem.new :time => deliverable.updated_at,
          :author => User.first, :flavor => :deliverable,
          :headline => "asked you #{with_teammates}to submit a " +
                       "#{deliverable.name} for #{deliverable.assignment.name}",
          :contents => deliverable.description,
          :actions => [
            ['Submit', [:url_for, deliverable]]
          ],
          :replies => []
      items << item
      
      if deliverable.deadline_passed_for_user? @s_user
        reply = FeedItem.new :time => deliverable.deadline_for_user(@s_user),
            :author => User.first, :flavor => :announcement,
            :contents => "The deadline has passed.",
            :actions => [], :replies => []
        item.replies << reply
      end
    end    
  end
  
  # Generates feed items for the published announcements.
  def self.add_announcements(items, user, options)
    # TODO(costan): distinguish between open announcements,
    #               semi-open (login required), and admin-only; right now,
    #               the default is semi-open, so we can post sensitive info
    return unless user
    
    # TODO(costan): get authors on notices
    Notice.all.each do |notice|
      item = FeedItem.new :time => notice.updated_at,
          :author => User.first, :flavor => :announcement,
          :headline => notice.subject.html_safe,
          :contents => notice.contents.html_safe,
          :actions => [],
          :replies => []
      items << item
    end
  end
  
  # Creates a new feed item with the given attributes.
  def initialize(attributes = {})
    attributes.each { |name, value| send :"#{name}=", value }
  end
end  # class Contents::FeedItem

end  # namespace Contents