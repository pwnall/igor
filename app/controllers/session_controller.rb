# Manages logging in and out of the application.
class SessionController < ApplicationController
  include Authpwn::SessionController
  
  # Sets up the 'session/welcome' view. No user is logged in.
  def welcome
    render :action => :new
  end
  private :welcome

  # Sets up the 'session/home' view. A user is logged in.
  def home
    # Pull information about the current user.
    @news_flavor = params[:flavor] ? params[:flavor].to_sym : nil
  end
  private :home
  
  # You shouldn't extend the session controller, so you can benefit from future
  # features, like Facebook / Twitter / OpenID integration. But, if you must,
  # you can do it here.
end
