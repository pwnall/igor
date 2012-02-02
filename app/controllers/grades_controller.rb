class GradesController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:index]
  before_filter :authenticated_as_user, :only => [:index]
  
  # GET /grades
  def index
    grades_by_metric_id = current_user.grades.index_by &:metric_id
    
    @grades = []
    Assignment.includes(:metrics).order('deadline DESC').each do |assignment|
      metrics = assignment.metrics.
          select { |metric| metric.visible_for? current_user }.
          map { |metric| [metric, grades_by_metric_id[metric.id]] }
      @grades << [assignment, metrics] unless metrics.empty?
    end
  end

  # GET /grades/editor
  def editor
    @subjects = Course.main.students.includes(:profile).sort_by(&:name)
    query = Course.main.assignments
    if params[:assignment_id]
      query = query.where(:id => params[:assignment_id])
    else
      query = query.where(['deadline < ?', Time.now]).order('deadline DESC')
    end
    
    @assignment = query.first
    @metrics = @assignment.metrics
    @grades = @assignment.grades.group_by { |g| [g.subject, g.metric] }
    
    respond_to do |format|
      format.html
    end
  end
  
  # POST /grades
  def create
    @grade = Grade.new params[:grade]
    @grade.grader = current_user
    if @grade.save
      if request.xhr?
        render :action => 'edit', :layout => false
      else
        render :action => 'edit'
      end
    else
      respond_to do |format|
        if request.xhr?
          head :not_acceptable
        else
          render :action => 'edit'
        end
      end
    end
  end
  
  # PUT /grades
  def update
    @grade = Grade.find params[:id]
    if params[:grade][:score].blank?
      @grade.destroy
      @grade = Grade.new params[:grade]
      success = true
    else
      @grade.grader = current_user
      success = @grade.update_attributes params[:grade]
    end
    if success
      if request.xhr?
        render :action => 'edit', :layout => false, :format => 'html'
      else
        render :action => 'edit'
      end
    else
      respond_to do |format|
        if request.xhr?
          head :not_acceptable
        else
          render :action => 'edit'
        end
      end
    end
  end

  # GET /grades/request_missing/0
  def request_missing
    @assignments = Assignment.all
  end

  # GET /grades/request_report/0
  def request_report
  end
  
  def missing
    assignments = Assignment.includes :deliverables, { :metrics => :assignment }
    @assignments = assignments
    if params[:filter_aid]
      assignments = assignments.where(:id => params[:filter_aid])
    end
    
    @metrics_by_id = assignments.map(&:metrics).flatten.index_by(&:id)
    
    gradeless_users = {}
    @users_by_id = {}
  
    assignments.each do |assignment|
      metrics = assignment.metrics
      metrics.select!(&:published) if params[:filtered_published]
      metric_ids = metrics.map(&:id)

      if assignment.deliverables.empty?
        # No deliverables (quiz?). Include all registered students.
        users = Profile.includes(:user).all.map(&:user).reject(&:admin?)
      else
        # Only consider students who submitted something for the assignment.
        deliverable_ids = assignment.deliverables.map(&:id)
        users = Submission.where(:deliverable_id => deliverable_ids).
                           includes(:user).map(&:user)
      end
          
      # find those without all the grades
      users.index_by(&:id).each do |user_id, user|
        user_grades = user.grades.select { |g| metric_ids.include? g.metric_id }
        next if user_grades.length == metric_ids.length
        
        # user found: add to list
        gradeless_users[user_id] ||= {}
        gradeless_users[user_id][assignment] =
            metric_ids - user_grades.map(&:metric_id)
        @users_by_id[user_id] = user
      end
    end
    
    @users = gradeless_users
  end

  # GET /grades/report/0
  def report
    # pull data
    pull_metrics false
    grades = Grade.where(:metric_id => @metrics.map(&:id)).
                   includes({:metric => :assignment}, :subject)
    @grades_by_uid_and_mid = {}
    @users = []
    grades.each do |grade|
      grade.users.each do |user|
        unless @grades_by_uid_and_mid.has_key? user.id
          @users << user
          @grades_by_uid_and_mid[user.id] = {}
        end
        @grades_by_uid_and_mid[user.id][grade.metric_id] = grade
      end
    end
    @names_by_uid = Hash[*((
      case params[:name_by]
      when 'name'
         @users.map { |u| [u.id, u.name] }
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
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0)  * grade.metric.weight : 0) }
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
    csv_text = (defined?(FasterCSV) ? FasterCSV : CSV).generate do |csv|
      @ordered_metrics = @assignments_by_aid.values.sort { |a, b| a.deadline <=> b.deadline }.map { |a| @metrics_by_aid[a.id].sort_by { |m| m.name } }.flatten
      
      csv << ['GRADES']
      csv << []
      csv << ['Name', 'Rec'] + @ordered_metrics.map { |m| "#{m.assignment.name}: #{m.name}" } + [params[:use_weights] ? 'Weighted Total' : 'Raw Total']
      @users.each do |user|
        section_number = 'None'
        if user.profile && user.profile.recitation_section
          section_number = user.profile.recitation_section.serial
        end
        csv << [@names_by_uid[user.id], section_number] +
               @ordered_metrics.map { |m| g = @grades_by_uid_and_mid[user.id][m.id]; next (g ? g.score || 'N' : 'N') } +
               [@totals_by_uid[user.id]]
      end
      csv << []
      
      csv << ['HISTOGRAM']
      @histogram_keys.each do |hk|
        csv << ["#{hk} - #{hk + @histogram_step - 1}", @histogram[hk] || 0]
      end
      csv << []
  
      csv << ['STATISTICS']
      csv << ['Count', @totals_by_uid.length]
      csv << ['Max', @totals_by_uid.values.max]
      csv << ['Mean', @totals_by_uid.values.inject(0.0) { |acc, v| acc + v } / @totals_by_uid.length ]
      sorted_scores = @totals_by_uid.values.sort
      if sorted_scores.length % 2
        median = sorted_scores[sorted_scores.length / 2]
      else
        median = sorted_scores[sorted_scores.length / 2, 2].inject(0.0) { |acc, v| acc + v } / 2.0 
      end
      csv << ['Median', median]
      csv << []
    end

    # push the CSV
    send_data csv_text, :filename => 'grades.csv', :type => 'text/csv', :disposition => 'inline'
  end
  
  def pull_metrics(only_published = true)
    @metrics = AssignmentMetric.includes :assignment
    @metrics = @metrics.where(:published => true) if only_published
    if params[:filter_aid] && !params[:filter_aid].empty?
      @metrics = @metrics.where(:assignment_id => params[:filter_aid].to_i)
    end
    
    @metrics_by_aid = {}
    @assignments_by_aid = {}
    @metrics.each do |m|
      @assignments_by_aid[m.assignment_id] ||= m.assignment 
      @metrics_by_aid[m.assignment_id] ||= []
      @metrics_by_aid[m.assignment_id] << m
    end    
  end  
  private :pull_metrics
end
