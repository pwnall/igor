require 'csv'

class GradesController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:reveal_mine]
  before_filter :authenticated_as_user, :only => [:reveal_mine]
  
  # GET /grades
  def index
  end

  # GET /grades/reveal_mine/0
  def request_report    
  end

  # GET /grades/request_missing/0
  def request_missing
    @assignments = Assignment.find(:all)
  end
  
  def missing
    if params[:filter_aid].blank?
      assignments = Assignment.find(:all, :include => [:deliverables, {:assignment_metrics => :assignment} ])
      @assignments = assignments
    else
      assignments = Assignment.find(:all, :conditions => {:id => params[:filter_aid]}, :include => [:deliverables, :assignment_metrics])
      @assignments = Assignment.find(:all)
    end
    
    @metrics_by_id = assignments.map(&:assignment_metrics).flatten.index_by(&:id)
    
    gradeless_users = {}
    @users_by_id = {}
  
    assignments.each do |assignment|
      metric_ids = (params[:filter_published] ? assignment.assignment_metrics.select(&:published) : assignment.assignment_metrics).map(&:id)

      # get the users who submitted
      users = Submission.find(:all, :conditions => {:deliverable_id => assignment.deliverables.map(&:id)}, :include => :user).map(&:user).index_by(&:id)
      # find those without all the grades
      users.each do |user_id, user|
        user_grades = user.grades.find(:all, :conditions => {:assignment_metric_id => metric_ids})
        next if user_grades.length == metric_ids.length
        
        # user found: add to list
        gradeless_users[user_id] ||= {}
        gradeless_users[user_id][assignment] = metric_ids - user_grades.map(&:assignment_metric_id)
        @users_by_id[user_id] = user
      end
    end
    
    @users = gradeless_users
  end

  # GET /graes/report/0
  def report
    # pull data
    pull_metrics false
    grades = Grade.find(:all, :conditions => {:assignment_metric_id => @metrics.map { |m| m.id }}, :include => [{:assignment_metric => :assignment}, :user])
    @grades_by_uid_and_mid = {}
    @users = []
    grades.each do |grade|
      unless @grades_by_uid_and_mid.has_key? grade.user_id
        @users << grade.user
        @grades_by_uid_and_mid[grade.user_id] = {}
      end
      @grades_by_uid_and_mid[grade.user_id][grade.assignment_metric_id] = grade
    end
    @names_by_uid = Hash[*((
      case params[:name_by]
      when 'real_name'
         @users.map { |u| [u.id, u.real_name] }
      when 'athena_username'
        @users.map { |u| [u.id, u.athena_id] }
      when 'username'
        @users.map { |u| [u.id, u.name] } 
      when 'email'
        @users.map { |u| [u.id, u.email] } 
      end).flatten)]
    
    # totals
    @totals_by_uid = {}
    @histogram = {}
    @histogram_step = params[:histogram_step].to_i || 1
    @users.each do |user|
      if params[:use_weights]
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0)  * grade.assignment_metric.weight : 0) }
      else
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0) : 0) }
      end
        
      hv = (@totals_by_uid[user.id] / @histogram_step).to_i * @histogram_step 
      @histogram[hv] = (@histogram[hv] || 0) + 1 
    end
    @histogram_keys = []; 0.step(@histogram.keys.max, @histogram_step) { |i| @histogram_keys << i }
    
    # sort users
    if params[:sort_by] == 'total'
      @users.sort! { |a, b| @totals_by_uid[b.id] <=> @totals_by_uid[a.id] }
    else
      @users.sort! { |a, b| @names_by_uid[a.id] <=> @names_by_uid[b.id] }
    end
    
    # generate the CSV
    csv_text = ''
    @ordered_metrics = @assignments_by_aid.values.sort { |a, b| a.deadline <=> b.deadline }.map { |a| @metrics_by_aid[a.id].sort_by { |m| m.name } }.flatten
    
    csv_text << CSV.generate_line(['GRADES'])
    csv_text << "\r\n"
    csv_text << CSV.generate_line(['Name', 'Rec'] + @ordered_metrics.map { |m| "#{m.assignment.name}: #{m.name}" } + [params[:use_weights] ? 'Weighted Total' : 'Raw Total'])
    csv_text << "\r\n"
    @users.each do |user|
      section_number = 'None'
      if user.profile && user.profile.recitation_section
        section_number = user.profile.recitation_section.serial
      end
      csv_text << CSV.generate_line([@names_by_uid[user.id], section_number] +
                        @ordered_metrics.map { |m| g = @grades_by_uid_and_mid[user.id][m.id]; next (g ? g.score || 'N' : 'N') } +
                        [@totals_by_uid[user.id]])
      csv_text << "\r\n"
    end
    csv_text << "\r\n\r\n"
    
    csv_text << CSV.generate_line(['HISTOGRAM'])
    csv_text << "\r\n"
    @histogram_keys.each do |hk|
      csv_text << CSV.generate_line(["#{hk} - #{hk + @histogram_step - 1}", @histogram[hk] || 0])
      csv_text << "\r\n"
    end
    csv_text << "\r\n\r\n"

    csv_text << CSV.generate_line(['STATISTICS'])    
    csv_text << "\r\n"    
    csv_text << CSV.generate_line(['Count', @totals_by_uid.length])
    csv_text << "\r\n"
    csv_text << CSV.generate_line(['Max', @totals_by_uid.values.max])
    csv_text << "\r\n"
    csv_text << CSV.generate_line(['Mean', @totals_by_uid.values.inject(0.0) { |acc, v| acc + v } / @totals_by_uid.length ])
    csv_text << "\r\n"
    sorted_scores = @totals_by_uid.values.sort
    if sorted_scores.length % 2
      median = sorted_scores[sorted_scores.length / 2]
    else
      median = sorted_scores[sorted_scores.length / 2, 2].inject(0.0) { |acc, v| acc + v } / 2.0 
    end
    csv_text << CSV.generate_line(['Median', median])
    csv_text << "\r\n"

    # push the CSV
    send_data csv_text, :filename => 'grades.csv', :type => 'text/csv', :disposition => 'inline'
  end
  
  # GET /grades/reveal_mine/0
  def reveal_mine
    pull_grades @s_user
    pull_metrics true
  end
  
  # XHR /grades/for_user/uid
  # XHR /grades/for_user/0?query=...
  def for_user
    if(params[:id].to_i != 0)
      @user = User.find(params[:id])
    else
      @user = User.find_first_by_query!(params[:query])
    end

    @updated = false    
    pull_grades @user
    show_or_update_for_user    
  end

  # XHR /grades/update_for_user/uid
  def update_for_user
    @user = User.find(params[:id])
    pull_grades @user
    
    p params[:grades]
    params[:grades].each do |mid_text, grade_score|
      mid = mid_text.to_i
      if grade_score.blank?
        # erase grade
        if @grades_by_mid.has_key? mid
          @grades_by_mid[mid].destroy
          @grades_by_mid.delete mid
        end
      else
        # add grade
        unless @grades_by_mid.has_key? mid
          @grades_by_mid[mid] = Grade.new(:assignment_metric_id => mid)
          @user.grades << @grades_by_mid[mid] 
        end
        if @grades_by_mid[mid].score != grade_score.to_i
          @grades_by_mid[mid].score = grade_score
          @grades_by_mid[mid].grader_user = @s_user
          @grades_by_mid[mid].save!
        end
      end     
    end
    
    @updated = true    
    show_or_update_for_user
  end
  
  private
  def pull_grades(user)
    @grades_by_mid = {}
    user.grades.each { |grade| @grades_by_mid[grade.assignment_metric_id] = grade }    
  end
  def pull_metrics(only_published = true)
    conditions = {}
    conditions[:published] = true if only_published
    conditions[:assignment_id] = params[:filter_aid].to_i if params[:filter_aid] && !params[:filter_aid].empty?
    @metrics = AssignmentMetric.find(:all, :conditions => conditions, :include => :assignment)
    
    @metrics_by_aid = {}
    @assignments_by_aid = {}
    @metrics.each do |m|
      @assignments_by_aid[m.assignment_id] ||= m.assignment 
      @metrics_by_aid[m.assignment_id] ||= []
      @metrics_by_aid[m.assignment_id] << m
    end    
  end
  
  def show_or_update_for_user
    pull_metrics false
        
    respond_to do |format|
      format.js { render :action => :for_user, :layout => false }
    end    
  end
end
