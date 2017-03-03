source 'https://rubygems.org'

ruby '>= 2.3'

gem 'rails', '>= 5.0.2'

gem 'pg', '>= 0.19.0', platforms: [:mri, :rbx]
gem 'activerecord-jdbcpostgresql-adapter', '>= 0', platform: :jruby,
    git: 'https://github.com/jruby/activerecord-jdbc-adapter.git'

# Core.
gem 'authpwn_rails', '>= 0.22.0'
gem 'file_blobs_rails', '>= 0.2.3'
gem 'foreman', '>= 0.82.0', require: false
gem 'jbuilder', '~> 2.4'
gem 'markdpwn', '>= 0.2.0', platforms: [:mri, :rbx]
gem 'mail', '>= 2.6.4'
gem 'nokogiri', '>= 1.6.7.2'
gem 'jc-validates_timeliness', '>= 3.1.1'

# Use Puma as the app server.
gem 'puma', '>= 3.7.1'

# Background processing.
gem 'delayed_job', '>= 4.1.2'
gem 'delayed_job_active_record', '>= 4.1.1'  # Required by delayed_job.

# PDF cover sheets.
gem 'prawn', '>= 2.0.2'
gem 'prawn-table', '>= 0.2.2'

# Instant feedback.
gem 'contained_mr', '>= 0.6.0'
#gem 'contained_mr', '>= 0.1.2', path: '../contained_mr'
gem 'pdf-reader', '>= 2.0.0'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# LDAP lookup.
gem 'net-ldap', '>= 0.14.0'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Profiling.
gem 'stackprof', '>= 0.2.10', platforms: :mri
gem 'flamegraph', '>= 0.9.5', platforms: :mri
gem 'rack-mini-profiler', '>= 0.10.2', require: false

# Bower integration.
gem 'bower-rails', '>= 0.10.0'

# Assets.
gem 'sass-rails', '>= 5.0.6'
gem 'jquery-rails', '>= 4.2.2'
gem 'font-awesome-rails', '>= 4.7.0.1'
gem 'uglifier', '>= 3.0.4'
gem 'autoprefixer-rails', '>= 6.7.6'
gem 'foundation-rails', '>= 6.3.0.0'
gem 'coffee-rails', '>= 4.2.1'
gem 'mini_racer', '>= 0.1.8'

# Image resizing.
#gem 'rmagick', '>= 2.16.0', platforms: [:mri, :rbx]
#gem 'rmagick4j', '>= 0', platform: :jruby

# Ruby standard gems.
# These gems should be included with every Ruby installation. For some reason,
# they are sometimes left out.
gem 'bigdecimal', '>= 1.3.1', require: false
gem 'io-console', '>= 0.4.6', require: false
gem 'json', '>= 1.8.6', require: false
gem 'minitest', '>= 5.10.1', require: false
gem 'net-telnet', '>= 0.1.1', require: false
gem 'openssl', '>= 2.0.3', require: false
gem 'psych', '>= 2.2.2', require: false
gem 'power_assert', '>= 1.0.1', require: false
gem 'rake', '>= 12.0.0', require: false
gem 'test-unit', '>= 3.2.3', require: false
gem 'xmlrpc', '>= 0.3.0', require: false

group :development, :test do
  gem 'binary_fixtures', '>= 0.1.3'
  gem 'byebug', platforms: :mri
end

group :development do
  gem 'web-console', '>= 3.1.1'
  gem 'binding_of_caller', '>= 0.7.3.pre1'
  # TODO(pwnall): Remove the git ref when 2.7.2 gets released.
  gem 'annotate', '>= 2.7.1',
      git: 'https://github.com/ctran/annotate_models.git',
      ref: '983d36f6a028daa289f31c0fe3fa83df36825d25'
  # TODO(pwnall): Remove version limitation when the rake issue gets fixed.
  #               https://github.com/stympy/faker/issues/780
  gem 'faker', ['>= 1.6.6', '< 1.7']
  gem 'railroady', '>= 1.5.1'
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
