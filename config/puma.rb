threads 4, 16
workers (ENV['PUMA_WORKERS'] || 1).to_i
port (ENV['PORT'] || 3000).to_i

preload_app! if ENV['RAILS_ENV'] == 'production'
