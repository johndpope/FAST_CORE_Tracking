# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  #config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  #config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  # Commenting below until we can make it work with notifier.rb
  # config.gem 'mislav-will_paginate', :version => '~> 2.3.2', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'binarylogic-searchlogic',
    :lib => 'searchlogic',
    :version => '>= 2.2.3',
    :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate',
    :lib => 'will_paginate',
    :version => '>= 2.3.11',
    :source => 'http://gems.github.com'
  config.gem 'json'
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below


RADIUS_ARRAY = [0.1,0.25,0.5,1,5,10,25,50,100]

GROUP_IMAGES = ['no_image.png','blue_small.png','red_small.png','green_small.png','yellow_small.png','purple_small.png','dark_blue_small.png','grey_small.png','orange_small.png']
MAP_MARKER_COLOR = ['blue','red',  'green', 'yellow','purple','black', 'gray', 'orange', 'white','brown',]

# various domains and URLs
COMPANY = "Numerex"
DOMAIN = "ublip.com"
MAIN_WEBSITE_URL = "http://www.ublip.com"
PRIVACY_URL = "http://ublip.com/privacy"
TERMS_URL = "http://ublip.com/terms"
PRICING_URL = "http://ublip.com/pricing"
MOTTO = "Location Matters"

# Email addresses
SUPPORT_EMAIL = "support@#{DOMAIN}"
ALERT_EMAIL = "alerts@#{DOMAIN}" #where notifications come from
ORDER_EMAIL = "orders@#{DOMAIN}"
ACCOUNT_EMAIL = "accounts@#{DOMAIN}"

SERVER_UTC_OFFSET = Time.now.utc_offset

ResultCount =25# Number of results per page
