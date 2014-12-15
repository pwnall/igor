if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
      email: {
        email_prefix: "[seven] ",
        sender_address: %{"Victor Costan" <costan@csail.mit.edu>},
        exception_recipients: %w{costan@mit.edu}
      }
end
