source 'https://rubygems.org'

gem 'rails',
    git: 'https://github.com/rails/rails', branch: 'master'

gem 'sprockets-rails',
    git: 'https://github.com/rails/sprockets-rails', branch: 'master'

gem 'arel',
    git: 'https://github.com/rails/arel', branch: 'master'

gem 'mysql2', '>= 0.3.18'

# Core.
gem 'authpwn_rails', '>= 0.17.2'
gem 'dynamic_form', '>= 1.1.4'
gem 'foreman', '>= 0.78.0', require: false
gem 'markdpwn', '>= 0.2.0'
gem 'mail', '>= 2.6.3'
gem 'nokogiri', '>= 1.6.6.2'
gem 'paperclip', '>= 4.2.1'
gem 'paperclip_database', '>= 2.3.1'
gem 'rack-noie', '>= 1.0', require: 'noie',
    git: 'https://github.com/juliocesar/rack-noie.git',
    ref: 'ce8313c6f327e5c524e3e903a05044ec31c98fd8'
gem 'rmagick', '>= 2.14.0'
gem 'jc-validates_timeliness', '>= 3.1.1'

gem 'thin', '>= 1.6.3'

# Background processing.
gem 'daemons'  # Required by delayed_job.
gem 'delayed_job', '>= 4.0.6'
gem 'delayed_job_active_record', '>= 4.0.3'  # Required by delayed_job.

# PDF cover sheets.
gem 'prawn', '~> 0.12.0'

# Instant feedback.
gem 'exec_sandbox', '>= 0.3.0'
gem 'pdf-reader', '>= 1.3.3'
gem 'zip', '>= 2.0.2'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# MIT WebSIS student lookup.
gem 'mit_stalker', '>= 1.0.6'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Assets.
gem 'sass-rails', '>= 5.0.3'
gem 'pwnstyles_rails', '>= 0.2.1'
#gem 'pwnstyles_rails', '>= 0.2.1', path: '../pwnstyles_rails'
gem 'jquery-rails', '>= 4.0.3'
gem 'coffee-rails', '>= 4.1.0'
gem 'uglifier', '>= 2.7.0'

# TODO(pwnall): allow therubyracer 0.12+ after Ubuntu crash gets fixed
#               https://github.com/cowboyd/therubyracer/issues/317
#gem 'therubyracer', '>= 0.12.1'

# Don't log BLOB values (file attachments).
group :development, :production do
  gem 'trim_blobs'
end

group :development, :test do
  gem 'binary_fixtures', '>= 0.1.3'
  #gem 'turn', '>= 0.9.7'
end

group :development do
  gem 'annotate', '>= 2.6.5'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'faker', '>= 1.4.3'
  gem 'railroady', '>= 1.3.0'
end

group :test do
  gem 'm'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
