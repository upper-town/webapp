# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  let(:described_class) { AlertComponent }

  describe "rendering" do
    it "does not render when content is blank" do
      render_inline(described_class.new) { "" }

      assert_no_selector("div")
    end

    it "renders with default variant and dismissible" do
      render_inline(described_class.new) { "Something happened." }

      assert_selector("div.alert.alert-info.alert-dismissible[role='alert']", text: "Something happened.")
      assert_selector("button.btn-close[data-bs-dismiss='alert'][aria-label='Close']")
    end

    it "renders with a custom variant" do
      render_inline(described_class.new(variant: :danger)) { "Error!" }

      assert_selector("div.alert.alert-danger", text: "Error!")
    end

    it "falls back to default variant for unknown values" do
      render_inline(described_class.new(variant: :unknown)) { "Fallback." }

      assert_selector("div.alert.alert-info", text: "Fallback.")
    end

    it "renders all valid variants" do
      described_class::VARIANTS.each do |variant|
        render_inline(described_class.new(variant:)) { "Message" }

        assert_selector("div.alert.alert-#{variant}", text: "Message")
      end
    end

    it "renders without dismiss button when dismissible is false" do
      render_inline(described_class.new(dismissible: false)) { "Persistent alert." }

      assert_selector("div.alert.alert-info", text: "Persistent alert.")
      assert_no_selector("div.alert-dismissible")
      assert_no_selector("button.btn-close")
    end
  end
end
