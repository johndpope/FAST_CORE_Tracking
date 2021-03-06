ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require "authenticated_test_helper"
require 'factory_girl'
require 'factories'
include AuthenticatedTestHelper

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
  
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
 
end

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  def without_timestamping_of(*klasses)
    if block_given?
      klasses.delete_if { |klass| !klass.record_timestamps }
      klasses.each { |klass| klass.record_timestamps = false }
      begin
        yield
      ensure
        klasses.each { |klass| klass.record_timestamps = true }
      end
    end
  end
end

def get_with_user(action, params, user)
  get action, params, {:user => users(user).id, :is_super_admin => users(user).is_super_admin}
end

