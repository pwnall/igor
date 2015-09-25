ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'capybara/rails'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  before { Capybara.current_driver = Capybara.javascript_driver }

  # Check every second for the given CSS selector, before executing the block.
  #
  # Useful for XHR requests that are purposely delayed.
  def wait_for_selector(selector)
    5.times do
      break if page.has_css? selector
      sleep 1
    end
    yield
  end
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
# Monkey-patch to share database transactions across threads.
#
# Without shared transactions, Capybara will not see the data in the database.
# Also, Delayed::Worker breaks in integration tests without this patch, perhaps
# due to a threading problem.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# The 'test/support/' directory contains helper methods for writing tests.
Dir[Rails.root.join('test', 'support', '*.rb')].each { |file| require file }
