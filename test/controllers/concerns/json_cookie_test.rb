require "test_helper"

class JsonCookieTest < ActiveSupport::TestCase
  def build_controller
    controller = Class.new do
      include JsonCookie

      attr_accessor :request
    end.new

    controller.request = build_request
    controller
  end

  describe "#json_cookie_jar" do
    it "returns cookie jar usable for read/write in test environment" do
      controller = build_controller

      assert_equal(controller.request.cookie_jar, controller.json_cookie_jar)
    end

    it "returns encrypted cookie jar in production" do
      rails_with_env("production") do
        controller = build_controller

        assert_equal(controller.request.cookie_jar.encrypted, controller.json_cookie_jar)
      end
    end
  end

  describe "#write_json_cookie and #read_json_cookie" do
    it "writes and reads a JSON object" do
      controller = build_controller
      data = { "key" => "value", "nested" => { "a" => 1 } }

      controller.write_json_cookie("test_cookie", data)

      assert_equal(data, controller.read_json_cookie("test_cookie"))
    end

    it "returns empty hash when cookie is blank" do
      controller = build_controller

      assert_equal({}, controller.read_json_cookie("nonexistent"))
    end

    it "returns empty hash when cookie value is invalid JSON" do
      controller = build_controller
      controller.request.cookie_jar["invalid_json"] = "not valid json"

      assert_equal({}, controller.read_json_cookie("invalid_json"))
    end

    it "returns empty hash when JSON parse raises TypeError" do
      controller = build_controller
      controller.request.cookie_jar["bad_type"] = 123

      assert_equal({}, controller.read_json_cookie("bad_type"))
    end

    it "returns empty hash when parsed value is blank" do
      controller = build_controller
      controller.write_json_cookie("empty", {})

      assert_equal({}, controller.read_json_cookie("empty"))
    end

    it "returns empty hash when parsed value is not a Hash" do
      controller = build_controller
      controller.write_json_cookie("array", [1, 2, 3])

      assert_equal({}, controller.read_json_cookie("array"))
    end
  end

  describe "#delete_json_cookie" do
    it "deletes the cookie" do
      controller = build_controller
      controller.write_json_cookie("to_delete", { "x" => 1 })

      assert_equal({ "x" => 1 }, controller.read_json_cookie("to_delete"))

      controller.delete_json_cookie("to_delete")

      assert_equal({}, controller.read_json_cookie("to_delete"))
    end
  end
end
