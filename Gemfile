source 'https://rubygems.org'

gem 'rails',
    git: 'https://github.com/rails/rails', branch: 'master'

# TODO(pwnall): Remove these when Rails 5 comes out.
gem 'sprockets-rails',
    git: 'https://github.com/rails/sprockets-rails', branch: 'master'
gem 'sprockets', git: 'https://github.com/rails/sprockets', branch: 'master'
gem 'sass-rails', git: 'https://github.com/rails/sass-rails', branch: 'master'
gem 'arel',
    git: 'https://github.com/rails/arel', branch: 'master'
gem 'rack', git: 'https://github.com/rack/rack', branch: 'master'
gem 'coffee-rails', git: 'https://github.com/rails/coffee-rails',
    branch: 'master'

gem 'pg', '>= 0.18.2'

# Core.
gem 'authpwn_rails', '>= 0.17.2',
    git: 'https://github.com/pwnall/authpwn_rails.git', branch: 'rails5'
gem 'dynamic_form', '>= 1.1.4'
gem 'foreman', '>= 0.78.0', require: false
gem 'markdpwn', '>= 0.2.0'
gem 'mail', '>= 2.6.3'
gem 'nokogiri', '>= 1.6.6.2'
gem 'paperclip', '>= 4.2.1'
gem 'paperclip_database', '>= 2.3.1',
    git: 'https://github.com/pwnall/paperclip_database.git', branch: 'rails5'
gem 'rack-noie', '>= 1.0', require: 'noie',
    git: 'https://github.com/juliocesar/rack-noie.git',
    ref: 'ce8313c6f327e5c524e3e903a05044ec31c98fd8'
gem 'rmagick', '>= 2.14.0'
gem 'jc-validates_timeliness', '>= 3.1.1'

gem 'puma', '>= 2.13.4', require: false

# Background processing.
gem 'delayed_job', '>= 4.0.6',
    git: 'https://github.com/pwnall/delayed_job.git', branch: 'rails5'
gem 'delayed_job_active_record', '>= 4.0.3',  # Required by delayed_job.
    git: 'https://github.com/pwnall/delayed_job_active_record.git',
    branch: 'rails5'

# PDF cover sheets.
gem 'prawn', '>= 2.0.2'
gem 'prawn-table', '>= 0.2.2'

# Instant feedback.
gem 'contained_mr', '>= 0.2.0'
#gem 'contained_mr', '>= 0.1.2', path: '../contained_mr'
gem 'exec_sandbox', '>= 0.3.0'
gem 'pdf-reader', '>= 1.3.3'
gem 'rubyzip', '>= 1.1.7', require: 'zip'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# LDAP lookup.
gem 'net-ldap', '>= 0.11'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Assets.
# gem 'sass-rails', '>= 5.0.3'
gem 'pwnstyles_rails', '>= 0.2.4'
# gem 'pwnstyles_rails', '>= 0.2.4', path: '../pwnstyles_rails'
gem 'jquery-rails', '>= 4.0.3'
# gem 'coffee-rails', '>= 4.1.0'
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
  gem 'spring'
end

group :test do
  gem 'minitest-spec-rails', '>= 5.3.0'
  gem 'capybara'
  gem 'launchy'
  gem 'poltergeist'
  gem 'mocha', '>= 1.1.0'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
