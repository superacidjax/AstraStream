workers Integer(ENV["WEB_CONCURRENCY"] || 2)
threads_count = Integer(ENV["RAILS_MAX_THREADS"] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV["PORT"]     || 3000
environment ENV["RACK_ENV"] || "development"

on_worker_boot do
  # Worker-specific setup for Rails 4.1 to 5.2, after 5.2 it's not needed
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
