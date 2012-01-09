unless Rails.env.test?
  Seven::Application.config.action_mailer.delivery_method = :smtp
end

Seven::Application.config.action_mailer.smtp_settings = {
  :address => "outgoing.mit.edu",
  :port => 25,
  :domain => "mit.edu",
}
