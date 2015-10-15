class SmtpServersController < ApplicationController
  before_action :authenticated_as_admin
  before_action :set_smtp_server

  # GET /_/smtp_server/edit
  def edit
  end

  # PATCH/PUT /smtp_servers/1
  def update
    if @smtp_server.update smtp_server_params
      redirect_to edit_smtp_server_url, notice: 'SMTP server saved.'
    else
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_smtp_server
      @smtp_server = SmtpServer.first || SmtpServer.new(auto_starttls: true)
    end

    # Only allow a trusted parameter "white list" through.
    def smtp_server_params
      params.require(:smtp_server).permit :host, :port, :domain, :user_name,
          :password, :from, :auth_kind, :auto_starttls
    end
end
