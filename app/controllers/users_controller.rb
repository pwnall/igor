class UsersController < ApplicationController
  before_filter :authenticated_as_admin, except:
      [:show, :new, :edit, :create, :update, :check_email]
  before_filter :authenticated_as_user, only: [:edit, :update]

  # GET /users
  def index
    @users = User.includes([:credentials, :profile]).to_a

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  def show
    @user = User.find_by_param params[:id]
    return bounce_user unless @user && @user.can_read?(current_user)

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
    @user = User.find_by_param params[:id]
    return bounce_user unless @user && @user.can_edit?(current_user)
  end

  # POST /users
  def create
    @user = User.new user_params

    respond_to do |format|
      if @user.save
        token = Tokens::EmailVerification.random_for @user.email_credential
        SessionMailer.email_verification_email(token, root_url).deliver

        # Root of trust: if no site admin exists, create one.
        if Role.where(name: 'admin').empty?
          Role.create! user: @user, name: 'admin'
        end

        format.html do
          redirect_to new_session_url,
              alert: 'Please check your e-mail to verify your account.'
        end
      else
        format.html { render action: :new }
      end
    end
  end

  # PUT /users/1
  def update
    @user = User.find_by_param params[:id]
    return bounce_user unless @user && @user.can_edit?(current_user)

    respond_to do |format|
      if @user.update_attributes user_params
        flash[:notice] = 'User information successfully updated.'
        format.html { redirect_to @user }
      else
        format.html { render action: :edit }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find_by_param params[:id]
    return bounce_user unless @user && @user.can_edit?(current_user)

    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  # XHR /users/check_email?email=...
  def check_email
    @email = params[:user][:email]
    @user = User.with_email @email

    render layout: false
  end

  # POST /users/1/set_admin?to=true
  def set_admin
    @user = User.find_by_param params[:id]
    if params[:to]
      Role.grant @user, 'admin'
    else
      Role.revoke @user, 'admin'
    end

    if @user.admin
      flash[:notice] = "#{@user.name} has been granted staff privileges."
    else
      flash[:notice] = "#{@user.name} no longer has staff privileges."
    end
    redirect_to users_url
  end

  # PUT /users/1/confirm_email
  def confirm_email
    @user = User.find_by_param params[:id]
    @user.email_credential.verified = true
    @user.email_credential.save!

    flash[:notice] = "#{@user.name}'s email has been manually confirmed."
    redirect_to users_url
  end

    # POST /users/1/impersonate
  def impersonate
    @user = User.find_by_param params[:id]
    return bounce_user('Cannot impersonate another admin.') if @user.admin?

    set_session_current_user @user
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  # Permit creating and updating user.
  def user_params
    return {} unless params[:user]

    if params[:user][:profile_attributes]
      params[:user][:profile_attributes].delete :id
    end

    params.require(:user).permit :email, :password, :password_confirmation,
        profile_attributes: [:athena_username, :name, :nickname, :university,
                             :department, :year]
  end
  private :user_params
end
