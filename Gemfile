source "https://rubygems.org"

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "devise", "~> 4.9", ">= 4.9.3"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "a9n"
gem "google-api-client"
gem "ransack"
gem "concurrent-ruby"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem "sentry-rails", "~> 5.15"
gem "sentry-ruby", "~> 5.15"
gem "sentry-sidekiq", "~> 5.15"
gem "sidekiq", "~> 7.2"
gem "sidekiq-cron", "~> 1.12"

group :development do
  gem "lefthook", "~> 1.5.5"
  gem "solargraph", "~> 0.50"
  gem "yard", "~> 0.9", require: false
  gem "yard-relative_markdown_links", "~> 0.5.0", require: false
end

group :development, :test do
  gem "brakeman", "~> 6.1", require: false
  gem "bullet", "~> 7.0"
  gem "bundler-audit", "~> 0.9", require: false
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "reek", "~> 6.1", require: false
  gem "standard", "~> 1.32", require: false
  gem "shoulda-matchers", "~> 5.0"
  gem "rails-controller-testing", "~> 1.0", ">= 1.0.5"
  gem "rspec-rails", "~> 6.1"
  gem "rubocop-rails", "~> 2.22", require: false
  gem "rubocop-rspec", "~> 2.25", require: false
end
