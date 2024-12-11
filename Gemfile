source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 8.0.0"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "uuid7"
gem "rudder-sdk-ruby"
gem "good_job"
gem "ostruct"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "pry-rails"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :production do
  gem "stackprof"
  gem "sentry-ruby"
  gem "sentry-rails"
end

group :test do
  gem "mocha"
  gem "simplecov", require: false
  gem "webmock"
end
