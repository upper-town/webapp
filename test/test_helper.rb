# frozen_string_literal: true

ENV["APP_ENV"] ||= "test"
ENV["RAILS_ENV"] ||= "test"

# Start SimpleCov before Rails loads so application code loaded during
# initialization (e.g. ApplicationModel via controller concerns) is tracked.
# See: https://github.com/simplecov-ruby/simplecov/issues/1082
if %w[true t 1 on yes y enable enabled].include?(ENV["COVERAGE"].to_s.strip.downcase)
  require "simplecov"
  require "simplecov-lcov"
  require_relative "../config/coverage"
end

require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rails/test_help"

require "minitest/rails"
require "webmock/minitest"

Rails.root.glob("test/support/extensions/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/config/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/setup/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/helpers/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/factories/*.rb").each do |file|
  require file
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors) if AppUtil.env_var_disabled?("COVERAGE")

    include ActiveJobTestSetup
    include CacheTestSetup
    include CurrentTestSetup
    include MailerTestSetup

    include ApplicationRecordTestFactoryHelper
    include EnvTestHelper
    include RailsEnvTestHelper
    include RequestTestHelper

    include Rails.application.routes.url_helpers
  end
end

module ActionDispatch
  class IntegrationTest
    include RequestTestSetup
  end
end
