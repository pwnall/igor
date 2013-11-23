Rails.application.config.middleware.use Rack::NoIE, minimum: 20,
    redirect: 'https://www.google.com/chrome'
