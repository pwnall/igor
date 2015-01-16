class CrashController < ApplicationController
  before_action :authenticated_as_admin

  # GET /crash/crash
  def crash
    raise Exception, "This is a crash handling test."
  end
end
