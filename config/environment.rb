# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_ev = File.join(Rails.root, 'config', 'app_ev.rb')
load(app_ev) if File.exists?(app_ev)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => ENV["SENDGRID_USERNAME"],
  :password => ENV["SENDGRID_PASSWORD"],
  :domain => ENV["SENDGRID_DOMAIN"],
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

#ActionMailer::Base.default_url_options[:host] = "http://localhost:3000"
