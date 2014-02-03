class CoursesController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /courses/1/edit
  def edit
    @course = Course.main

    respond_to do |format|
      format.html  # edit.html.erb
    end
  end

  # PUT /courses/1
  def update
    @course = Course.main

    respond_to do |format|
      if @course.update_attributes course_update_params
        format.html do
          redirect_to root_url, :notice => "#{@course.number} course settings updated"
        end
      else
        format.html { render :action => :edit }
      end
    end
  end

  # Permit updating courses
  def course_update_params
    params.require(:course).permit :number, :title, :email, :ga_account,
        :has_recitations, :has_surveys, :has_teams, :section_size
  end
  private :course_update_params

end
