class WelcomeController < ApplicationController
  before_filter :authenticated_as_user, :only => [:home]

  def index
    # HACK(costan): remove this when all the routes have been moved to the
    #               session controller.
    redirect_to :controller => :sessions, :action => :index
  end
  
  def home
    @profile = @s_user.profile
    @student_info = @s_user.student_info
    
    @submissions = Submission.find(:all, :conditions => {:user_id => @s_user.id}, :order => 'updated_at DESC')
    @assignments_h = Hash[*(@submissions.map { |s| [s.deliverable.assignment.id, s.deliverable.assignment] }.flatten)]
    @feedbacks = AssignmentFeedback.find(:all, :conditions => {:user_id => @s_user.id, :assignment_id => @assignments_h.keys })
    @feedbacks_h = Hash[*(@feedbacks.map { |f| [f.assignment_id, f] }.flatten)]
    
    @notice_statuses = @s_user.notice_statuses
    @notice_statuses.each { |status| status.mark_seen! }
    @notice_statuses.sort! { |a, b| b.notice.created_at <=> a.notice.created_at }
  end
end
