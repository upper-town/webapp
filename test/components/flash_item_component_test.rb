# frozen_string_literal: true

require "test_helper"

class FlashItemComponentTest < ViewComponent::TestCase
  let(:described_class) { FlashItemComponent }

  describe "render?" do
    it "does not render when content is blank or nil" do
      render_inline(described_class.new(["notice", ""]))
      assert_no_selector("div")

      render_inline(described_class.new(["notice", nil]))
      assert_no_selector("div")
    end
  end

  describe "key mapping" do
    it "maps :alert to :warning variant" do
      render_inline(described_class.new(["alert", "Watch out"]))

      assert_selector("div.alert.alert-warning", text: "Watch out.")
    end

    it "maps :notice to :success variant" do
      render_inline(described_class.new(["notice", "All good"]))

      assert_selector("div.alert.alert-success", text: "All good.")
    end

    it "passes through other keys as-is" do
      render_inline(described_class.new(["danger", "Error occurred"]))

      assert_selector("div.alert.alert-danger", text: "Error occurred.")
    end

    it "converts string keys to symbols" do
      component = described_class.new(["notice", "Done"])

      assert_equal(:success, component.key)
    end
  end

  describe "string value" do
    it "renders a single string message" do
      render_inline(described_class.new(["notice", "Saved successfully"]))

      assert_selector("div.alert.alert-success", text: "Saved successfully.")
      assert_no_selector("ul")
    end

    it "renders with dismissible alert by default" do
      render_inline(described_class.new(["notice", "Hello"]))

      assert_selector("div.alert.alert-dismissible")
      assert_selector("button.btn-close")
    end
  end

  describe "array value" do
    it "renders multiple messages as a list" do
      render_inline(described_class.new(["danger", ["First error", "Second error"]]))

      assert_selector("ul li", count: 2)
      assert_selector("ul li", text: "First error.")
      assert_selector("ul li", text: "Second error.")
    end

    it "renders a single-element array without a list" do
      render_inline(described_class.new(["notice", ["Only one"]]))

      assert_no_selector("ul")
      assert_selector("div.alert", text: "Only one.")
    end
  end

  describe "hash value" do
    it "renders content from hash" do
      render_inline(described_class.new(["warning", { content: "Heads up" }]))

      assert_selector("div.alert.alert-warning", text: "Heads up.")
    end

    it "renders multiple content items as a list" do
      render_inline(described_class.new(["danger", { content: ["Error one", "Error two"] }]))

      assert_selector("ul li", count: 2)
      assert_selector("ul li", text: "Error one.")
      assert_selector("ul li", text: "Error two.")
    end

    it "passes dismissible option to alert" do
      render_inline(described_class.new(["notice", { content: "Persistent", dismissible: false }]))

      assert_selector("div.alert.alert-success", text: "Persistent.")
      assert_no_selector("div.alert-dismissible")
      assert_no_selector("button.btn-close")
    end

    it "does not render when hash content is blank" do
      render_inline(described_class.new(["notice", { content: "" }]))

      assert_no_selector("div")
    end

    it "supports html_safe option" do
      render_inline(described_class.new(["notice", { content: "<strong>Bold</strong>", html_safe: true }]))

      assert_selector("div.alert strong", text: "Bold")
    end

    it "escapes HTML when html_safe is not set" do
      render_inline(described_class.new(["notice", { content: "<strong>Bold</strong>" }]))

      assert_no_selector("strong")
      assert_text("<strong>Bold</strong>.")
    end
  end

  describe "ActiveModel::Errors value" do
    it "renders error full messages" do
      model = User.new
      model.errors.add(:email, :blank)

      render_inline(described_class.new(["danger", model.errors]))

      assert_selector("div.alert.alert-danger")
      assert_text(/email/i)
    end
  end

  describe "hash value with content: ActiveModel::Errors" do
    it "renders error full messages from hash content" do
      model = User.new
      model.errors.add(:email, :blank)
      model.errors.add(:password, "is too short")

      render_inline(described_class.new(["danger", { content: model.errors }]))

      assert_selector("div.alert.alert-danger")
      assert_text(/email can't be blank/i)
      assert_text(/password is too short/i)
    end
  end
end
