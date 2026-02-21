# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  describe "rendering" do
    it "does not render when content is blank" do
      render_inline(AlertComponent.new) { "" }

      assert_no_selector("div")
    end

    it "renders with default variant and dismissible" do
      render_inline(AlertComponent.new) { "Something happened." }

      assert_selector("div.alert.alert-info.alert-dismissible[role='alert']", text: "Something happened.")
      assert_selector("button.btn-close[data-bs-dismiss='alert'][aria-label='Close']")
    end

    it "renders with a custom variant" do
      render_inline(AlertComponent.new(variant: :danger)) { "Error!" }

      assert_selector("div.alert.alert-danger", text: "Error!")
    end

    it "falls back to default variant for unknown values" do
      render_inline(AlertComponent.new(variant: :unknown)) { "Fallback." }

      assert_selector("div.alert.alert-info", text: "Fallback.")
    end

    it "renders all valid variants" do
      AlertComponent::VARIANTS.each do |variant|
        render_inline(AlertComponent.new(variant:)) { "Message" }

        assert_selector("div.alert.alert-#{variant}", text: "Message")
      end
    end

    it "renders without dismiss button when dismissible is false" do
      render_inline(AlertComponent.new(dismissible: false)) { "Persistent alert." }

      assert_selector("div.alert.alert-info", text: "Persistent alert.")
      assert_no_selector("div.alert-dismissible")
      assert_no_selector("button.btn-close")
    end
  end
end
