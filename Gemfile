source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 7.2.1"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "uuid7"
gem "rudder-sdk-ruby"
gem "good_job"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "pry", git: "https://github.com/superacidjax/pry.git"
  gem "pry-rails"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "mocha"
end
