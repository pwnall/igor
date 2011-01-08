class CoursesController < ApplicationController
  before_filter :authenticated_as_admin
  
  in_place_edit_for_boolean :course, :has_recitations
  [:number, :ga_account, :title].each do |field|
    in_place_edit_for :course, field
  end
  
  # GET /courses
  def index
    @courses = Course.all

    respond_to do |format|
      format.html  # index.html.erb
    end
  end
  
  # GET /courses/new
  def new
    @course = Course.new
    
    respond_to do |format|
      format.html  # new.html.erb
    end
  end
  
  # GET /courses/1/edit
  def edit
    @course = Course.find params[:id]
    
    respond_to do |format|
      format.html  # edit.html.erb
    end
  end
    
  # PUT /courses/1
  def update
    @course = Course.find params[:id]
    
    respond_to do |format|
      if @course.update_attributes params[:course]
        format.html { redirect_to courses_url }
      else
        format.html { render :action => :edit }
      end
    end
  end

  # DELETE /courses/1
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
    end
  end
end
