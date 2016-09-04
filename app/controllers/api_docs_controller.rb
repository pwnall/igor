class ApiDocsController < ApplicationController
  before_action :authenticated_as_user
  skip_before_action :verify_authenticity_token  

  # GET /_/api_docs
  def index
  end
end
