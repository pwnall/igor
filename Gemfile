source 'https://rubygems.org'

gem 'rails', '>= 5.0.0.beta1'

gem 'pg', '>= 0.18.2'

# Core.
gem 'authpwn_rails', '>= 0.17.2',
    git: 'https://github.com/pwnall/authpwn_rails.git', branch: 'rails5'
gem 'dynamic_form', '>= 1.1.4'
gem 'foreman', '>= 0.78.0', require: false
gem 'jbuilder', '~> 2.2'
gem 'markdpwn', '>= 0.2.0'
gem 'mail', '>= 2.6.3'
gem 'nokogiri', '>= 1.6.7.1'
gem 'paperclip', '>= 4.2.1'
gem 'paperclip_database', '>= 2.3.1',
    git: 'https://github.com/pwnall/paperclip_database.git', branch: 'rails5'
gem 'rack-noie', '>= 1.0', require: 'noie',
    git: 'https://github.com/juliocesar/rack-noie.git',
    ref: 'ce8313c6f327e5c524e3e903a05044ec31c98fd8'
gem 'rmagick', '>= 2.15.4'
gem 'jc-validates_timeliness', '>= 3.1.1'

# Use Puma as the app server.
gem 'puma', '>= 2.14.0'

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
gem 'contained_mr', '>= 0.4.1'
#gem 'contained_mr', '>= 0.1.2', path: '../contained_mr'
gem 'exec_sandbox', '>= 0.3.0'
gem 'pdf-reader', '>= 1.3.3'
gem 'rubyzip', '>= 1.1.7', require: 'zip',
    git: 'https://github.com/rubyzip/rubyzip.git',
    ref: 'a3ca219bdb37b3e369263f121a4adc3da01b95ad'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# LDAP lookup.
gem 'net-ldap', '>= 0.11'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Bower integration.
gem 'bower-rails', '>= 0.10.0'

# Assets.
gem 'sass-rails', '>= 5.0.3'
gem 'jquery-rails', '>= 4.0.3'
gem 'coffee-rails', '>= 4.1.1'
gem 'font-awesome-rails', '>= 4.5.0.0'
gem 'uglifier', '>= 2.7.0'
# TODO(pwnall): Relax the restriction once Rails 5 support gets re-merged into
#               autoprefixer. https://github.com/ai/autoprefixer-rails/pull/73
gem 'autoprefixer-rails', '= 6.1.0'
gem 'foundation-rails', '>= 5.5.3.2',
    git: 'https://github.com/pwnall/foundation-rails.git', branch: 'f6'

# TODO(pwnall): allow therubyracer 0.12+ after Ubuntu crash gets fixed
#               https://github.com/cowboyd/therubyracer/issues/317
#gem 'therubyracer', '>= 0.12.1'

# Don't log BLOB values (file attachments).
group :development, :production do
  gem 'trim_blobs'
end

group :development, :test do
  gem 'binary_fixtures', '>= 0.1.3'
  gem 'byebug'
end

group :development do
  gem 'web-console', '>= 3.0.0'
  gem 'binding_of_caller', '>= 0.7.3.pre1'

  gem 'annotate', '>= 2.6.5'
  gem 'faker', '>= 1.4.3'
  gem 'railroady', '>= 1.3.0'
  gem 'spring'
  gem 'listen', '~> 3.0.5'
end

group :test do
  gem 'minitest-spec-rails', '>= 5.3.0'
  gem 'capybara', '>= 2.5.0'
  gem 'launchy', '>= 2.4.3'
  gem 'poltergeist', '>= 1.6.0'
  gem 'mocha', '>= 1.1.0'
  gem 'mechanize', require: false
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
