if ENV['RAILS_ENV'] == 'production'
  threads 4, 16
else
  threads 1, 1
end
workers (ENV['PUMA_WORKERS'] || 1).to_i
port (ENV['PORT'] || 3000).to_i

preload_app! if ENV['RAILS_ENV'] == 'production'
