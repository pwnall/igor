class TokensController < ApplicationController
  def spend
    @token = Token.where(:token => params[:token]).first
    
    if @token.nil?
      flash[:error] = 'Invalid token (did you click this link before?)'
    else
      spent = self.send @token.action.to_sym, @token.argument
      @token.destroy if spent
    end
        
    unless performed?
      respond_to do |format|
        format.html { redirect_to sessions_path }
        format.xml do
          if token
            head :ok
          else
            render :xml => nil, :status => :unprocessable_entity
          end
        end
      end
    end
  end
  
  def confirm_email(dummy)
    user = @token.user
    user.active = true
    
    if user.save
      session[:user_id] = user.id
      return true
    else
      flash[:error] = "Unexpected error :("
      return false
    end
  end
  
  def login_once(dummy)
    user = @token.user
    user.password = "\0"
    user.password_confirmation = "\0"
    # user.active = true  # The user confirmed a token, should be good to go.
      
    if user.save
      session[:user_id] = user.id
      flash[:notice] = "Logged in as #{user.name}. Please change your password now."
      redirect_to edit_password_user_path(user)
      return true
    else
      flash[:error] = "Unexpected error :("
      return false
    end
  end
end
