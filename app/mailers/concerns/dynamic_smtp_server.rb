# Included by the mailers that use SMTP settings defined in SmtpServer.
module DynamicSmtpServer
  extend ActiveSupport::Concern

  def set_smtp
    smtp_server = SmtpServer.first
    if smtp_server.nil?
      mail.perform_deliveries = false
    else
      mail.delivery_method.settings.merge! smtp_server.action_mailer_options
      mail.from = smtp_server.from
    end
  end
  private :set_smtp

  included do
    after_action :set_smtp
  end
end
