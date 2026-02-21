# frozen_string_literal: true

require "test_helper"

class AppUtilTest < ActiveSupport::TestCase
  let(:described_class) { AppUtil }

  describe ".env_var_enabled?" do
    it "returns true for enabled values" do
      [
        "true",
        "t",
        "1",
        "on",
        "yes",
        "y",
        "enable",
        "enabled"
      ].each do |value|
        env_with_values("MY_VAR" => value) do
          assert(described_class.env_var_enabled?(:my_var), "Expected true for #{value.inspect}")
        end
      end
    end

    it "returns true regardless of case and surrounding whitespace" do
      [
        " \tTRUE \n",
        " \tT \n",
        " \t1 \n",
        " \tON \n",
        " \tYES \n",
        " \tY \n",
        " \tENABLE \n",
        " \tENABLED \n"
      ].each do |value|
        env_with_values("MY_VAR" => value) do
          assert(described_class.env_var_enabled?(:my_var), "Expected true for #{value.inspect}")
        end
      end
    end

    it "returns false for non-enabled values" do
      [
        "",
        "  ",
        "false",
        "0",
        "off",
        "no",
        "anything"
      ].each do |value|
        env_with_values("MY_VAR" => value) do
          assert_not(described_class.env_var_enabled?(:my_var), "Expected false for #{value.inspect}")
        end
      end
    end

    it "returns false when env var is not set and no default" do
      env_without_values("MY_VAR") do
        assert_not(described_class.env_var_enabled?(:my_var))
      end
    end

    it "uses the default value when env var is not set" do
      env_without_values("MY_VAR") do
        assert(described_class.env_var_enabled?(:my_value, default: "true"))
        assert_not(described_class.env_var_enabled?(:my_value, default: "false"))
      end
    end

    it "normalizes the env var name" do
      env_with_values("MY_VAR" => "true") do
        assert(described_class.env_var_enabled?("MY_VAR"))
        assert(described_class.env_var_enabled?("my_var"))
        assert(described_class.env_var_enabled?(" my_var "))
        assert(described_class.env_var_enabled?(:my_var))
      end
    end
  end

  describe ".env_var_disabled?" do
    it "returns the inverse of env_var_enabled?" do
      env_with_values("MY_VAR" => "true") do
        assert_not(described_class.env_var_disabled?(:my_var))
      end

      env_with_values("MY_VAR" => "false") do
        assert(described_class.env_var_disabled?(:my_var))
      end

      env_without_values("MY_VAR") do
        assert(described_class.env_var_disabled?(:my_var))
      end
    end
  end

  describe ".normalize_env_var_name" do
    it "upcases and strips the name and returns nil for nil" do
      [
        ["my_var",     "MY_VAR"],
        [" my_var ",   "MY_VAR"],
        ["MY_VAR",     "MY_VAR"],
        [" MY_VAR  ",  "MY_VAR"],
        [:my_var,      "MY_VAR"]
      ].each do |input, expected|
        assert_equal(expected, described_class.normalize_env_var_name(input), "Failed for #{input.inspect}")
      end

      assert_nil(described_class.normalize_env_var_name(nil))
    end
  end

  describe ".running_assets_precompile?" do
    it "returns true when SECRET_KEY_BASE_DUMMY is enabled" do
      env_with_values("SECRET_KEY_BASE_DUMMY" => "1") do
        assert(described_class.running_assets_precompile?)
      end
    end

    it "returns false when SECRET_KEY_BASE_DUMMY is not set" do
      env_without_values("SECRET_KEY_BASE_DUMMY") do
        assert_not(described_class.running_assets_precompile?)
      end
    end
  end

  describe ".show_active_record_log" do
    it "sets ActiveRecord logger to stdout" do
      original_logger = ActiveRecord::Base.logger

      described_class.show_active_record_log

      assert_instance_of(ActiveSupport::Logger, ActiveRecord::Base.logger)
      assert_equal($stdout, ActiveRecord::Base.logger.instance_variable_get(:@logdev).dev)
    ensure
      ActiveRecord::Base.logger = original_logger
    end
  end

  describe ".webapp_host" do
    it "returns APP_HOST value" do
      env_with_values("APP_HOST" => "example.com") do
        assert_equal("example.com", described_class.webapp_host)
      end
    end

    it "defaults to upper.town" do
      env_without_values("APP_HOST") do
        assert_equal("upper.town", described_class.webapp_host)
      end
    end
  end

  describe ".webapp_port" do
    it "returns APP_PORT value" do
      env_with_values("APP_PORT" => "8080") do
        assert_equal("8080", described_class.webapp_port)
      end
    end

    it "defaults to 3000" do
      env_without_values("APP_PORT") do
        assert_equal("3000", described_class.webapp_port)
      end
    end
  end
end
