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
  
  # The items that are readable by a user.
  #
  # Returns an array of FeedItems objects sorted in order of relevance.
  def self.for(user, options = {})
    items = []
    
    if user
      add_feedbacks items, user, options
      add_submissions items, user, options
    end
    add_grades items, user, options
    add_deliverables items, user, options
    
    items.sort_by(&:time).reverse
  end
  
  # Generates feed items for the user's submitted feedback.
  def self.add_feedbacks(items, user, options)
    user.assignment_feedbacks.each do |feedback|
      item = FeedItem.new :time => feedback.updated_at,
          :author => feedback.user,
          :headline => "submitted feedback on #{feedback.assignment.name}",
          :contents => '',
          :actions => [['Edit', [:edit_assignment_feedback_path, feedback]]]
      items << item
    end
  end

  # Generates feed items for the submissions that the user can see.
  def self.add_submissions(items, user, options)
    user.connected_submissions.each do |submission|
      item = FeedItem.new :time => submission.updated_at,
          :author => submission.user,
          :headline => "submitted #{submission.deliverable.name} for " +
                       submission.deliverable.assignment.name,
          :contents => number_to_human_size(submission.code.size) +
                       " #{submission.code_content_type} file",
          :actions => [
            ['View', [:file_submission_path, submission, {:inline => true}]],
            ['Download', [:file_submission_path, submission, {:inline => false}]]
          ]
      items << item
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
           :author => last_grade.grader,
           :headline => "released the grades for #{assignment.name}",
           :contents => '',
           :actions => [
             ['View', [:reveal_mine_grades_path]]
           ]
      items << item
    end
  end
  
  # Generates feed items for the published deliverables.   
  def self.add_deliverables(items, user, options)
    Deliverable.includes(:assignment).each do |deliverable|
      next unless deliverable.visible_for_user?(user)
      
      # TODO(costan): get authors on deliverables
      item = FeedItem.new :time => deliverable.updated_at,
          :author => User.first,
          :headline => "posted #{deliverable.name} for " +
                       deliverable.assignment.name,
          :contents => deliverable.description,
          :actions => [
            ['Submit', [:url_for, deliverable]]
          ]
      items << item
    end
  end
  
  # Creates a new feed item with the given attributes.
  def initialize(attributes = {})
    attributes.each { |name, value| send :"#{name}=", value }
  end
end  # class Contents::FeedItem

end  # namespace Contents