class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  include DynamicSmtpServer
end
