source 'https://rubygems.org'

gem 'rails', '>= 5.0.0.beta3'

gem 'pg', '>= 0.18.4'

# Core.
gem 'authpwn_rails', '>= 0.20.0',
    git: 'https://github.com/pwnall/authpwn_rails.git', branch: 'rails5'
gem 'foreman', '>= 0.78.0', require: false
gem 'jbuilder', '~> 2.4'
gem 'markdpwn', '>= 0.2.0'
gem 'mail', '>= 2.6.4'
gem 'nokogiri', '>= 1.6.7.2'
gem 'paperclip', '>= 4.3.5'
gem 'paperclip_database', '>= 2.3.1',
    git: 'https://github.com/pwnall/paperclip_database.git', branch: 'rails5'
gem 'rack-noie', '>= 1.0', require: 'noie',
    git: 'https://github.com/juliocesar/rack-noie.git',
    ref: 'ce8313c6f327e5c524e3e903a05044ec31c98fd8'
gem 'rmagick', '>= 2.15.4'
gem 'jc-validates_timeliness', '>= 3.1.1'

# Use Puma as the app server.
gem 'puma', '>= 3.2.0'

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
gem 'contained_mr', '>= 0.4.1'
#gem 'contained_mr', '>= 0.1.2', path: '../contained_mr'
gem 'exec_sandbox', '>= 0.3.0'
gem 'pdf-reader', '>= 1.4.0'
gem 'rubyzip', '>= 1.1.7', require: 'zip',
    git: 'https://github.com/rubyzip/rubyzip.git',
    ref: 'a3ca219bdb37b3e369263f121a4adc3da01b95ad'

# Gravatar fall-back avatars.
gem 'gravatar-ultimate', '>= 2.0.0'

# LDAP lookup.
gem 'net-ldap', '>= 0.14.0'

# Report production exceptions.
gem 'exception_notification', '>= 4.0.1'

# Profiling.
gem 'stackprof', '>= 0.2.8'
gem 'flamegraph', '>= 0.1.0'
gem 'rack-mini-profiler', '>= 0.9.9.2', require: false

# Bower integration.
gem 'bower-rails', '>= 0.10.0'

# Assets.
gem 'sass-rails', '>= 5.0.4'
gem 'jquery-rails', '>= 4.1.0'
gem 'coffee-rails', '>= 4.1.1'
gem 'font-awesome-rails', '>= 4.5.0.1'
gem 'uglifier', '>= 3.0.0'
gem 'autoprefixer-rails', '>= 6.3.4'
gem 'foundation-rails', '>= 6.2.0.0',
  git: 'https://github.com/spark008/foundation-rails.git',
  branch: 'f6_2+fix_7a3fd7b'

# Heap integration.
gem 'heap-helpers', '>= 0.1'

# TODO(pwnall): allow therubyracer 0.12+ after Ubuntu crash gets fixed
#               https://github.com/cowboyd/therubyracer/issues/317
#gem 'therubyracer', '>= 0.12.1'

group :development, :test do
  gem 'binary_fixtures', '>= 0.1.3'
  gem 'byebug'
end

group :development do
  gem 'web-console', '>= 3.0.0'
  gem 'binding_of_caller', '>= 0.7.3.pre1'
  gem 'annotate', '>= 2.7.0',
      git: 'https://github.com/ctran/annotate_models.git', branch: 'develop'
  gem 'faker', '>= 1.4.3'
  gem 'railroady', '>= 1.3.0'
  gem 'listen', '~> 3.0.5'
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
