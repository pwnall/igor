class GradesController < ApplicationController
  include GradeEditor

  before_action :set_current_course
  before_action :authenticated_as_user, only: [:index]
  before_action :authenticated_as_course_grader, only: [:editor, :create]
  before_action :authenticated_as_course_editor, except:
      [:index, :editor, :create]

  # GET /6.006/grades
  def index
    grades_by_metric_id = current_user.grades_for(current_course).
        index_by(&:metric_id)
    comments_by_metric_id = current_user.comments_for(current_course).
        index_by(&:metric_id)
    @recitation = current_user.recitation_section_for(current_course)

    @assignments = []
    @assignment_metrics = {}
    @assignment_grades = {}
    @assignment_comments = {}
    current_course.assignments.includes(:metrics).by_deadline.
        each do |assignment|
      assignment_metrics = assignment.metrics.select { |metric|
        metric.can_read? current_user
      }.sort_by(&:to_param)
      next if assignment_metrics.empty?

      @assignments << assignment
      @assignment_metrics[assignment] = assignment_metrics
      @assignment_grades[assignment] = assignment_metrics.map do |metric|
        grades_by_metric_id[metric.id]
      end
      @assignment_comments[assignment] = assignment_metrics.map do |metric|
        comments_by_metric_id[metric.id]
      end
    end
  end

  # GET /6.006/grades/editor
  def editor
    @subjects = current_course.students.includes(:profile).sort_by &:name

    if params[:assignment_id]
      @assignment = current_course.assignments.find params[:assignment_id]
    else
      @assignment = current_course.most_relevant_assignment_for_graders
    end

    unless @assignment
      respond_to do |format|
        format.html { render :editor_blank }
      end
      return
    end

    @metrics = @assignment.metrics
    respond_to do |format|
      format.html
    end
  end

  # XHR POST /6.006/grades
  def create
    success = Grade.transaction do
      grade = find_or_build_feedback Grade, grade_params
      grade.act_on_user_input grade_params[:score]
    end
    if success
      render 'grades/edit', layout: false
    else
      head :not_acceptable
    end
  end

  # GET /6.006/grades/request_missing
  def request_missing
    @assignments = current_course.assignments
  end

  # GET /6.006/grades/request_report
  def request_report
    render layout: 'assignments'
  end

  # POST /6.006/grades/missing
  def missing
    assignments = current_course.assignments.includes :deliverables,
                                                      metrics: :assignment
    @assignments = assignments
    unless params[:filter_aid].blank?
      assignments = current_course.assignments.where id: params[:filter_aid]
      @assignment = assignments.first
    else
      @assignment = nil
    end

    @metrics_by_id = assignments.map(&:metrics).flatten.index_by(&:id)

    gradeless_subjects = {}
    assignments.each do |assignment|
      metrics = assignment.metrics
      metrics.select!(&:released) if params[:filter_released]
      metric_ids = metrics.map(&:id)

      if assignment.deliverables.empty?
        # No deliverables (quiz?). Include all registered students.
        subjects = current_course.students
      else
        # Only consider students / teams who submitted something for the assignment.
        deliverable_ids = assignment.deliverables.map(&:id)
        subjects = Submission.where(deliverable_id: deliverable_ids).
                              includes(:subject).map(&:subject)
      end

      # find those without all the grades
      subjects.index_by(&:name).each do |_, subject|
        subject_grades = Grade.where(subject: subject) do |grade|
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

  # POST /6.006/grades/report
  def report
    # pull data
    pull_metrics false
    grades = Grade.includes(:subject, metric: :assignment).
                   where(metric: @metrics)

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
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0) * grade.metric.weight * grade.metric.assignment.weight : 0) }
      else
        @totals_by_uid[user.id] = @grades_by_uid_and_mid[user.id].values.inject(0) { |acc, grade| acc + (grade ? (grade.score || 0) * grade.metric.weight : 0) }
      end

      hv = (@totals_by_uid[user.id] / @histogram_step).to_i * @histogram_step
      @histogram[hv] = (@histogram[hv] || 0) + 1
    end
    @histogram_keys = []
    unless @histogram.empty?
      0.step(@histogram.keys.max, @histogram_step) { |i| @histogram_keys << i }
    end

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
        registration = user.registration_for(current_course)
        if registration && registration.recitation_section
          section_number = registration.recitation_section.serial
        else
          section_number = ''
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

      mean = if @totals_by_uid.empty?
        0
      else
        @totals_by_uid.values.sum / @totals_by_uid.length
      end
      csv << ['Mean', mean]
      sorted_scores = @totals_by_uid.values.sort
      if sorted_scores.length % 2
        median = sorted_scores[sorted_scores.length / 2]
      else
        median = sorted_scores[sorted_scores.length / 2, 2].inject(0.0) { |acc, v| acc + v } / 2.0
      end
      csv << ['Median', median]
      csv << []
    end

    # Serve the CSV.

    # NOTE: We don't really need a CSP here, because we're serving a CSV file.
    #       We're adding it in to make sure no terrible incident
    #       happens where a browser's MIME type sniffer does something dumb.
    #       See https://xkcd.com/327/
    response.headers['Content-Security-Policy'] = "default-src 'none'"
    send_data csv_text, :filename => 'grades.csv', :type => 'text/csv', :disposition => 'inline'
  end

  def pull_metrics(only_released = true)
    @metrics = current_course.assignment_metrics.includes :assignment
    @metrics = @metrics.where(:released => true) if only_released
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
end
