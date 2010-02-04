class CoursesController < ApplicationController
  before_filter :authenticated_as_admin
  
  in_place_edit_for_boolean :course, :has_recitations
  [:number, :ga_account, :title].each do |field|
    in_place_edit_for :course, field
  end
  
  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
end
