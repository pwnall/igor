class UsersController < ApplicationController
  before_action :authenticated_as_admin, except:
      [:show, :new, :edit, :create, :update, :check_email]
  before_action :authenticated_as_user, only: [:show, :edit, :update]

  # GET /users
  def index
    @users = User.includes([:credentials, :profile, :roles]).to_a

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  def show
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_read?(current_user)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @user.build_profile

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_edit?(current_user)
  end

  # POST /users
  def create
    @user = User.new user_params

    respond_to do |format|
      if @user.save
        # Root of trust: if no site admin exists, create one.
        # NOTE: The admin is set before the confirmation e-mail is sent out,
        #       because sending the e-mail might crash.
        if Role.where(name: 'admin').empty?
          Role.create! user: @user, name: 'admin'
        end

        if SmtpServer.first
          token = Tokens::EmailVerification.random_for @user.email_credential
          SessionMailer.email_verification_email(token, root_url).deliver

          format.html do
            redirect_to new_session_url,
                alert: 'Please check your e-mail to verify your account.'
          end
        else
          @user.email_credential.update! verified: true
          format.html do
            redirect_to new_session_url, notice: 'You may log in now.'
          end
        end
      else
        format.html { render action: :new }
      end
    end
  end

  # PUT /users/1
  def update
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_edit?(current_user)

    respond_to do |format|
      if @user.update_attributes user_params
        format.html do
          redirect_to @user, notice: 'User information successfully updated.'
        end
      else
        format.html { render action: :edit }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_edit?(current_user)

    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  # XHR POST /_/users/check_email
  def check_email
    @email = params[:user][:email]
    @user = User.with_email @email
    @ldap_info = EmailResolver.resolve @email unless @email.blank?

    render layout: false
  end

  # POST /users/1/set_admin?to=true
  def set_admin
    @user = User.with_param(params[:id]).first!
    if params[:to] == 'true'
      Role.grant @user, 'admin'
      flash[:notice] = "#{@user.name} has been granted site admin privileges."
    elsif params[:to] == 'false'
      Role.revoke @user, 'admin'
      flash[:notice] = "#{@user.name} no longer has site admin privileges."
    else
      flash[:notice] = 'Invalid site admin flag value.'
    end

    redirect_to users_url
  end

  # PUT /users/1/confirm_email
  def confirm_email
    @user = User.with_param(params[:id]).first!
    @user.email_credential.verified = true
    @user.email_credential.save!

    flash[:notice] = "#{@user.name}'s email has been manually confirmed."
    redirect_to users_url
  end

    # POST /users/1/impersonate
  def impersonate
    @user = User.with_param(params[:id]).first!
    if @user.has_role?('admin')
      return bounce_user('Cannot impersonate another admin.')
    end

    set_session_current_user @user
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
  def user_params
    return {} unless params[:user]

    if params[:user][:profile_attributes] && params[:user][:profile_attributes][:id]
      user = User.with_param(params[:id]).first!
      params[:user][:profile_attributes][:id] = user.profile.id
    end

    params.require(:user).permit :email, :password, :password_confirmation,
        profile_attributes: [:name, :nickname, :university,
                             :department, :year, :id]
  end
  private :user_params
end
