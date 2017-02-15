if Rails.env.production? || ENV['EXCEPTION_NOTIFIER']
  Rails.application.config.middleware.use ExceptionNotification::Rack,
      email: {
        email_prefix: "[igor] ",
        sender_address: %{"Victor Costan" <costan@csail.mit.edu>},
        exception_recipients: %w{costan@alum.mit.edu spark008@alum.mit.edu},
        mailer_parent: 'ExceptionMailer',
      }
end
