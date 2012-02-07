source :rubygems

gem 'rails', '>= 3.2.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '>= 0.3.11'

gem 'json', '>= 1.5.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.2.3'
  gem 'coffee-rails', '>= 3.2.1'
  gem 'uglifier', '>= 1.2.3'
  
  gem 'therubyracer', '>= 0.9.9'
end

gem 'jquery-rails', '>= 2.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Core.
gem 'authpwn_rails', '>= 0.10.9'
gem 'dynamic_form', '>= 1.1.4'
gem 'fastercsv', '>= 1.5.4', :platforms => [:mri_18]
gem 'nokogiri', '>= 1.5.0'
gem 'paperclip', :git => 'git://github.com/patshaughnessy/paperclip.git',
                 :ref => 'c295bc4e78b84044296f3a03157c097b50161bc5'
gem 'pwnstyles_rails', '>= 0.1.8'
gem 'rmagick', '>= 2.13.1'
gem 'validates_timeliness', '>= 3.0.8'

# Background processing.
gem 'daemonz', '>= 0.3.5'
gem 'daemons'  # Required by delayed_job.
gem 'delayed_job', '>= 3.0.1'
gem 'delayed_job_active_record', '>= 0.3.2'  # Required by delayed_job.

# PDF cover sheets.
gem 'prawn', '~> 0.12.0'

# Code grading.
gem 'exec_sandbox', '>= 0.1.2'

# Gravatar fall-back avatars.
gem 'gravtastic', '>= 3.2.6'

# MIT WebSIS student lookup.
gem 'mit_stalker', '>= 1.0.3'

# MIT Stellar integration.
gem 'stellar', '>= 0.3.1'

group :development, :test do
  gem 'annotate', '>= 2.4.1.beta',
      :git => 'git://github.com/ctran/annotate_models.git'
  gem 'rspec-rails', '>= 2.8.1'
  gem 'thin', '>= 1.3.1'
  gem 'webrat'
end
