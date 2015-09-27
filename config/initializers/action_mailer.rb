unless Rails.env.test?
  Rails.application.config.action_mailer.delivery_method = :smtp
end
