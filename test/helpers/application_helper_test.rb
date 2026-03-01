require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  describe "#default_title" do
    it "returns the default title" do
      assert_equal("upper.town", default_title)
    end
  end

  describe "#no_script" do
    it "returns the no-script message" do
      assert_equal(
        "JavaScript is currently disabled on your browser. This website doesn't work without JavaScript.",
        no_script
      )
    end
  end

  describe "#current_page_for_nav?" do
    it "returns true for exact match of /admin" do
      request.env["PATH_INFO"] = "/admin"
      assert(current_page_for_nav?("/admin"))
    end

    it "returns false for /admin when on /admin/users" do
      request.env["PATH_INFO"] = "/admin/users"
      assert_not(current_page_for_nav?("/admin"))
    end

    it "returns true for /admin/users when on /admin/users/123" do
      request.env["PATH_INFO"] = "/admin/users/123"
      assert(current_page_for_nav?("/admin/users"))
    end
  end
end
