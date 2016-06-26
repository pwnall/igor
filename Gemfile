source 'https://rubygems.org'

gem 'rails', '>= 5.0.0.rc2'

gem 'pg', '>= 0.18.4', platforms: [:mri, :rbx]
gem 'activerecord-jdbcpostgresql-adapter', '>= 0', platform: :jruby,
    git: 'https://github.com/jruby/activerecord-jdbc-adapter.git'

# Core.
gem 'authpwn_rails', '>= 0.20.0',
    git: 'https://github.com/pwnall/authpwn_rails.git', branch: 'rails5'
gem 'foreman', '>= 0.82.0', require: false
gem 'jbuilder', '~> 2.4'
gem 'markdpwn', '>= 0.2.0', platforms: [:mri, :rbx]
gem 'mail', '>= 2.6.4'
gem 'nokogiri', '>= 1.6.7.2'
gem 'paperclip', '>= 4.3.5'
gem 'paperclip_database', '>= 2.3.1',
    git: 'https://github.com/pwnall/paperclip_database.git', branch: 'rails5'
gem 'rack-noie', '>= 1.0', require: 'noie',
    git: 'https://github.com/juliocesar/rack-noie.git',
    ref: 'ce8313c6f327e5c524e3e903a05044ec31c98fd8'
gem 'rmagick', '>= 2.15.4', platforms: [:mri, :rbx]
gem 'rmagick4j', '>= 0', platform: :jruby
gem 'jc-validates_timeliness', '>= 3.1.1'

# Use Puma as the app server.
gem 'puma', '>= 3.4.0'

# Background processing.
gem 'delayed_job', '>= 4.0.6',
    git: 'https://github.com/collectiveidea/delayed_job.git', branch: 'master'
gem 'delayed_job_active_record', '>= 4.1.0',  # Required by delayed_job.
    git: 'https://github.com/collectiveidea/delayed_job_active_record.git',
    branch: 'master'

# PDF cover sheets.
gem 'prawn', '>= 2.0.2'
gem 'prawn-table', '>= 0.2.2'

# Instant feedback.
gem 'contained_mr', '>= 0.6.0'
#gem 'contained_mr', '>= 0.1.2', path: '../contained_mr'
gem 'pdf-reader', '>= 1.4.0'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# LDAP lookup.
gem 'net-ldap', '>= 0.14.0'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Profiling.
gem 'stackprof', '>= 0.2.8', platforms: :mri
gem 'flamegraph', '>= 0.9.5', platforms: :mri
gem 'rack-mini-profiler', '>= 0.9.9.2', require: false

# Bower integration.
gem 'bower-rails', '>= 0.10.0'

# Assets.
gem 'sass-rails', '>= 5.0.4'
gem 'jquery-rails', '>= 4.1.0'
gem 'font-awesome-rails', '>= 4.6.3.1'
gem 'uglifier', '>= 3.0.0'
gem 'autoprefixer-rails', '>= 6.3.6.1'
gem 'foundation-rails', '>= 6.2.3.0'
gem 'coffee-rails', '>= 4.1.1'
gem 'mini_racer', '>= 0.1.4'

# Heap integration.
gem 'heap-helpers', '>= 0.1'

group :development, :test do
  gem 'binary_fixtures', '>= 0.1.3'
  gem 'byebug', platforms: :mri
end

group :development do
  gem 'web-console', '>= 3.0.0'
  gem 'binding_of_caller', '>= 0.7.3.pre1'
  gem 'annotate', '>= 2.7.1'
  gem 'faker', '>= 1.4.3'
  gem 'railroady', '>= 1.3.0'
  gem 'listen', '~> 3.0.8'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'minitest-spec-rails', '>= 5.3.0'
  gem 'capybara', '>= 2.6.2'
  gem 'launchy', '>= 2.4.3'
  gem 'poltergeist', '>= 1.9.0'
  gem 'mocha', '>= 1.1.0'
  gem 'mechanize', '>= 2.7.4', require: false
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
