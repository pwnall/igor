class DeadlineExtensionsController < ApplicationController
  include DateSelectParamParser

  before_action :set_current_course
  before_action :authenticated_as_course_editor
  before_action :set_assignment, except: [:destroy]

  # GET /6.006/assignments/1/extensions
  def index
    @extension = DeadlineExtension.new subject: @assignment
  end

  # POST /6.006/assignments/1/extensions
  def create
    @extension = build_extension @assignment, extension_params
    @extension.grantor = current_user

    respond_to do |format|
      if @extension.save
        format.html do
          redirect_to assignment_extensions_url(assignment_id: @assignment,
              course_id: current_course),
              notice: "Extension granted to #{@extension.user.name}."
        end
      else
        @assignment.extensions.reload
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
            notice: "#{@extension.user.name}'s 'extension was revoked."
      end
    end
  end

  def set_assignment
    @assignment = current_course.assignments.find params[:assignment_id]
  end
  private :set_assignment

  def extension_params
    params.require(:deadline_extension).permit :user_id, :due_at
  end
  private :extension_params
end
