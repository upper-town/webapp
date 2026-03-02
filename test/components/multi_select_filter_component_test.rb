require "test_helper"

class MultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { MultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders multi-select with data attributes for Stimulus controller" do
      render_inline(
        described_class.new(
          form: build_form,
          param_name: "game_ids",
          options: [["Minecraft", 1]],
          selected_ids: []
        )
      )

      assert_selector("[data-controller='multi-select-filter']")
      assert_selector("[data-multi-select-filter-param-name-value='game_ids']")
      assert_selector("button[data-bs-toggle='dropdown']")
    end

    it "renders clear button when request and selected_ids are present" do
      req = build_request(url: "http://uppertown.test/servers?game_ids[]=1&period=month")
      render_inline(
        described_class.new(
          form: build_form,
          param_name: "game_ids",
          options: [["Minecraft", 1]],
          selected_ids: ["1"],
          request: req
        )
      )

      assert_selector("a.btn", text: I18n.t("admin.shared.clear_search"))
      clear_link = page.find("a.btn", text: I18n.t("admin.shared.clear_search"))
      assert_includes(clear_link["href"], "period=month")
      assert_not_includes(clear_link["href"], "game_ids")
    end

    it "does not render clear button when request is nil" do
      render_inline(
        described_class.new(
          form: build_form,
          param_name: "game_ids",
          options: [["Minecraft", 1]],
          selected_ids: ["1"],
          request: nil
        )
      )

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end

    it "does not render clear button when selected_ids is empty" do
      req = build_request(url: "http://uppertown.test/servers?period=month")
      render_inline(
        described_class.new(
          form: build_form,
          param_name: "game_ids",
          options: [["Minecraft", 1]],
          selected_ids: [],
          request: req
        )
      )

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end
  end

  describe "#show_clear_button?" do
    it "returns true when request and selected_ids are present" do
      req = build_request(url: "http://uppertown.test/servers")
      component = described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [],
        selected_ids: ["1"],
        request: req
      )
      render_inline(component)

      assert(component.show_clear_button?)
    end

    it "returns false when request is nil" do
      component = described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [],
        selected_ids: ["1"],
        request: nil
      )
      render_inline(component)

      assert_not(component.show_clear_button?)
    end

    it "returns false when selected_ids is empty" do
      req = build_request(url: "http://uppertown.test/servers")
      component = described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [],
        selected_ids: [],
        request: req
      )
      render_inline(component)

      assert_not(component.show_clear_button?)
    end
  end

  describe "#clear_url" do
    it "returns url with param removed while preserving other params" do
      req = build_request(url: "http://uppertown.test/servers?game_ids[]=1&period=month")
      component = described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [],
        selected_ids: ["1"],
        request: req
      )
      render_inline(component)

      clear_url = component.clear_url
      assert_includes(clear_url, "period=month")
      assert_not_includes(clear_url, "game_ids")
    end

    it "returns nil when request is nil" do
      component = described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [],
        selected_ids: ["1"],
        request: nil
      )
      render_inline(component)

      assert_nil(component.clear_url)
    end
  end
end
