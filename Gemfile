source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails"

# TEMP: LambdaCable
gem "aws-sdk-apigatewaymanagementapi"
gem "aws-sdk-dynamodb"

gem "bootstrap_form"
gem "faker"
gem "importmap-rails"
gem "lamby"
gem "mysql2", "~> 0.5"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "jbuilder"

group :development, :test do
  gem "debug"
  gem "puma"
end

group :development do
  # gem "hotwire-livereload"
  gem "planetscale_rails"
  gem "redis"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
  gem 'lograge'
  gem 'lambda_punch'
end
