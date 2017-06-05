source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Hold the sprockets gems at their older versions because the current versions selected by Bundler
# when updating the Rails gem to 4.2.5 cause Sufia to break.  Hopefully, we will be able to remove
# the following two lines at some point in the future.  For now we need them.
gem 'sprockets-rails', '~> 2.3.3'
gem 'sprockets', '~> 3.3.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0', '< 4'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'xray-rails'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Use sqlite3 as the database for testing
  gem 'sqlite3'

  # Our dev/test gems
  gem 'rspec-rails'
  gem 'jettywrapper'
  gem 'rails-helper'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'phantomjs', '2.1.1', require: 'phantomjs/poltergeist'
  gem "simplecov", require: false
  gem 'coveralls', require: false
end

# Our dev/prod gems
group :development, :production do
  gem "clamav"
  gem "pg"
end

#Sufia's gems
gem 'sufia', '6.6.1'
gem 'kaminari', git: 'https://github.com/jcoyne/kaminari.git', branch: 'sufia'

gem 'rsolr', '~> 1.0.6'
gem 'devise'
gem 'devise-guests', '~> 0.3'

# Our gems
gem 'orcid'
gem 'ezid-client'
gem "hydra-role-management"
gem 'omniauth-cas'
gem 'net-ldap'
gem 'jquery-ui-rails'
gem 'gelf'
gem 'lograge'
gem 'archive'
gem 'rubyzip'
