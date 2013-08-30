source :rubygems
ruby '1.9.3'

gem 'rails', '~> 3.2.14'

gem 'mysql2', '>= 0.3.13'
gem 'json', '>= 1.7.7'

# Core.
gem 'authpwn_rails', '>= 0.14.0'
gem 'dynamic_form', '>= 1.1.4'
gem 'markdpwn', '>= 0.1.6'
gem 'nokogiri', '>= 1.6.0'
gem 'paperclip', git: 'https://github.com/patshaughnessy/paperclip.git',
                 ref: '89d53623028a7f1f74cdc2726110486ada0061f9'
gem 'rack-noie', '>= 1.0', require: 'noie'
gem 'rmagick', '>= 2.13.2'
gem 'validates_timeliness', '>= 3.0.14'

# Help stupid bundler with version resolution.
gem 'rdoc', '~> 3.12'

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
gem 'mit_stalker', '>= 1.0.4'

# MIT Stellar integration.
gem 'stellar', '>= 0.3.2'

# UI
gem 'best_in_place', '>= 2.1.0'

# Help bundler do gem resolution.
gem 'rdoc', '~> 3.12'

group :assets do
  gem 'sass-rails', '>= 3.2.6'
  gem 'pwnstyles_rails', '>= 0.1.29'
  # gem 'pwnstyles_rails', '>= 0.1.29', path: '../pwnstyles_rails'

  gem 'jquery-rails', '>= 3.0.4'
  gem 'coffee-rails', '~> 3.2'
  gem 'uglifier', '>= 2.2.1'

  gem 'therubyracer', '>= 0.12.0'
end

group :development, :test do
  gem 'rspec-rails', '>= 2.14.0'
  gem 'thin', '>= 1.5.1'
  gem 'webrat', '>= 0.7.3'
end

group :development do
  gem 'annotate', '>= 2.6.0.beta1',
                  git: 'https://github.com/ctran/annotate_models.git'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'debugger'
  gem 'railroady', '>= 1.0.6'
end

group :production do
  gem 'trim_blobs'
end
