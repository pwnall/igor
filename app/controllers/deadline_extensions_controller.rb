class DeadlineExtensionsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor
  before_action :set_assignment, except: [:destroy]

  layout 'assignments'

  # GET /6.006/assignments/1/extensions
  def index
    @extension = DeadlineExtension.new subject: @assignment
    @extension.due_at = @extension.default_due_at
  end

  # POST /6.006/assignments/1/extensions
  def create
    @extension = DeadlineExtension.new extension_params
    @extension.subject = @assignment
    @extension.grantor = current_user

    respond_to do |format|
      if @extension.save
        format.html do
          redirect_to assignment_extensions_url(assignment_id: @assignment,
              course_id: current_course),
              notice: "Extension granted to #{@extension.user.name}."
        end
      else
        format.html do
          flash.now[:notice] = 'The extension could not be created.'
          render :index
        end
      end
    end
  end

  # DELETE /6.006/extensions/1
  def destroy
    @extension = DeadlineExtension.find params[:id]
    @extension.destroy

    respond_to do |format|
      format.html do
        redirect_to assignment_extensions_url(assignment_id: @extension.subject,
            course_id: current_course),
            notice: "#{@extension.user.name}'s extension was revoked."
      end
    end
  end

  def set_assignment
    @assignment = current_course.assignments.find params[:assignment_id]
  end
  private :set_assignment

  def extension_params
    params.require(:deadline_extension).permit :user_exuid, :due_at
  end
  private :extension_params
end
