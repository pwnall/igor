class GradesController < ApplicationController
  before_action :authenticated_as_admin, :except => [:index]
  before_action :authenticated_as_user, :only => [:index]

  # GET /grades
  def index
    grades_by_metric_id = current_user.grades.index_by(&:metric_id)
    @recitation = current_user.recitation_section

    @assignments = []
    @assignment_metrics = {}
    @assignment_grades = {}
    Assignment.includes(:metrics).by_deadline.each do |assignment|
      assignment_metrics = assignment.metrics.select do |metric|
        metric.can_read? current_user
      end
      next if assignment_metrics.empty?

      @assignments << assignment
      @assignment_metrics[assignment] = assignment_metrics
      @assignment_grades[assignment] = assignment_metrics.map do |metric|
        grades_by_metric_id[metric.id]
      end
    end
  end

  # GET /grades/editor
  def editor
    @subjects = Course.main.students.includes(:profile).sort_by(&:name)
    query = Course.main.assignments
    if params[:assignment_id]
      query = query.where(:id => params[:assignment_id])
    else
      query = query.by_deadline.where('deadlines.due_at < ?', Time.now)
    end

    @assignment = query.first || Assignment.last
    unless @assignment
      respond_to do |format|
        format.html { render :action => :editor_blank }
      end
      return
    end

    @metrics = @assignment.metrics
    @grades = @assignment.grades.includes(:comment, :subject).
                          group_by { |g| [g.subject, g.metric] }
    respond_to do |format|
      format.html
    end
  end

  # POST /grades
  def create
    case params[:grade][:subject_type]
    when 'User'
      user = User.with_param(params[:grade][:subject_id]).first!
      params[:grade][:subject_id] = user.id
    when 'Team'
      # Teams don't use external UIDs yet.
    else
      head :not_acceptable
      return
    end

    @grade = Grade.where(
        subject_type: params[:grade][:subject_type],
        subject_id: params[:grade][:subject_id],
        metric_id: params[:grade][:metric_id]).first
    if @grade
      if params[:grade][:score].blank?
        # Delete a grade. This will remove its comment as well.
        @grade.destroy
        @grade = Grade.new metric: @grade.metric  # Render a clean slate.
        params[:comment][:comment] = ''
        success = true
      else
        # Create / update a grade.
        @grade.grader = current_user
        success = @grade.update_attributes grade_params
      end
    else
      @grade = Grade.new grade_params
      @grade.grader = current_user
      success = @grade.save
    end

    if success
      comment = @grade.comment
      if comment
        if params[:comment][:comment].empty?
          # Delete a grade's comment.
          comment.comment = nil
          comment.destroy
        else
          # Update a grade's comment.
          comment.grader = current_user
          success = comment.update_attributes grade_comment_params
        end
      else
        unless params[:comment][:comment].empty?
          # Create a comment for a grade.
          comment = GradeComment.new grade_comment_params
          comment.grade = @grade
          comment.grader = current_user
          success = comment.save
        end
      end
    end

    if success
      if request.xhr?
        render action: 'edit', layout: false
      else
        render action: 'edit'
      end
    else
      if request.xhr?
        head :not_acceptable
      else
        render action: 'edit'
      end
    end
  end

  # GET /grades/request_missing/0
  def request_missing
    @assignments = Assignment.all
  end

  # GET /grades/request_report/0
  def request_report
    render layout: 'assignments'
  end

  def missing
    course = Course.main
    assignments = course.assignments.includes :deliverables,
                                              metrics: :assignment
    @assignments = assignments
    unless params[:filter_aid].blank?
      assignments = course.assignments.where(id: params[:filter_aid])
      @assignment = assignments.first
    else
      @assignment = nil
    end

    @metrics_by_id = assignments.map(&:metrics).flatten.index_by(&:id)

    gradeless_subjects = {}
    assignments.each do |assignment|
      metrics = assignment.metrics
      metrics.select!(&:published) if params[:filter_published]
      metric_ids = metrics.map(&:id)

      if assignment.deliverables.empty?
        # No deliverables (quiz?). Include all registered students.
        subjects = course.students
      else
        # Only consider students / teams who submitted something for the assignment.
        deliverable_ids = assignment.deliverables.map(&:id)
        subjects = Submission.where(deliverable_id: deliverable_ids).
                              includes(:subject).map(&:subject)
      end

      # find those without all the grades
      subjects.index_by(&:name).each do |_, subject|
        subject_grades = Grade.with_subject subject do |grade|
          metric_ids.include? grade.metric_id
        end
        next if subject_grades.length == metric_ids.length

        # user found: add to list
        gradeless_subjects[subject] ||= {}
        gradeless_subjects[subject][assignment] =
            metric_ids - subject_grades.map(&:metric_id)
      end
    end

    @subjects = gradeless_subjects
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
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0)  * grade.metric.assignment.weight : 0) }
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
      @ordered_metrics = @assignments_by_aid.values.sort_by(&:due_at).map { |a| @metrics_by_aid[a.id].sort_by { |m| m.name } }.flatten

      csv << ['GRADES']
      csv << []
      csv << ['Name', 'Rec'] + @ordered_metrics.map { |m| "#{m.assignment.name}: #{m.name}" } + [params[:use_weights] ? 'Weighted Total' : 'Raw Total']
      @users.each do |user|
        section_number = 'None'
        if user.registration && user.registration.recitation_section
          section_number = user.registration.recitation_section.serial
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

  # Permits updating grades.
  def grade_params
    params.require(:grade).permit :subject_id, :subject_type, :metric_id, :score
  end
  private :grade_params

  def grade_comment_params
    params.require(:comment).permit :comment
  end
  private :grade_comment_params
end
