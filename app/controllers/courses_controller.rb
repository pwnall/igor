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
      if @course.update_attributes params[:course]
        format.html { redirect_to courses_url }
      else
        format.html { render :action => :edit }
      end
    end
  end
end
