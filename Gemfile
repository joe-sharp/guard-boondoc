# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "boondoc"
gem "ostruct" # guard's DSL requires it; no longer a default gem in Ruby 4.0
gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.21"
gem "rubocop-performance", require: false
gem "rubocop-rspec", require: false

group :development do
  gem "guard-rspec", "~> 4.7" # the Guardfile runs this repo's own plugin
  gem "guard-rubocop", "~> 1.5"
end

gem "sharp_style_rubocop", "~> 0.1.5"
