source 'https://rubygems.org'

gem 'rails', '>= 4.0.1'

gem 'mysql2', '>= 0.3.15'

# Core.
gem 'authpwn_rails', '>= 0.15.1'
gem 'dynamic_form', '>= 1.1.4'
gem 'markdpwn', '>= 0.1.7'
gem 'mail', git: 'https://github.com/pwnall/mail.git', ref: 'mime2_25'
gem 'nokogiri', '>= 1.6.0'
gem 'paperclip', '>= 4.0.0'
gem 'paperclip_database', '>= 2.2.1',
    git: 'https://github.com/pwnall/paperclip_database.git',
    ref: 'contents_style'
gem 'rack-noie', '>= 1.0', require: 'noie'
gem 'rmagick', '>= 2.13.2'
gem 'validates_timeliness', '>= 3.0.14'

# Background processing.
gem 'daemonz', '>= 0.3.9'
gem 'daemons'  # Required by delayed_job.
gem 'delayed_job', '>= 4.0.0'
gem 'delayed_job_active_record', '>= 4.0.0'  # Required by delayed_job.

# PDF cover sheets.
gem 'prawn', '~> 0.12.0'

# Instant feedback.
gem 'exec_sandbox', '>= 0.2.3'
gem 'pdf-reader', '>= 1.3.0'
gem 'zip', '>= 2.0.2'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 1.0.3'

# MIT WebSIS student lookup.
gem 'mit_stalker', '>= 1.0.6'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.0'

# UI
gem 'best_in_place', '>= 2.1.0',
                     git: 'https://github.com/bernat/best_in_place.git'

# Assets.
gem 'sass-rails', '>= 4.0.1'
gem 'pwnstyles_rails', '>= 0.1.33'
#gem 'pwnstyles_rails', '>= 0.1.33', path: '../pwnstyles_rails'
gem 'jquery-rails', '>= 3.1.0'
gem 'jquery-ui-rails', '>= 4.1.1'
gem 'coffee-rails', '>= 4.0.1'
gem 'uglifier', '>= 2.4.0'
gem 'therubyracer', '>= 0.12.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.5'

# Don't log BLOB values (file attachments).
group :development, :production do
  gem 'trim_blobs'
end

group :development, :test do
  gem 'minitest-rails', '>= 0.9.2'
  gem 'binary_fixtures', '>= 0.1.2'
  gem 'thin', '>= 1.6.1'
  gem 'turn', '>= 0.9.6'
end

group :development do
  gem 'annotate', '>= 2.6.1'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'debugger'
  gem 'railroady', '>= 1.0.6'
end

group :production do
  gem 'thin', '>= 1.6.1'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
