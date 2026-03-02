require "test_helper"

class Admin::FetchableMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::FetchableMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders fetchable dropdown with turbo-frame for remote options" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        search_url_params: { only_with_votes: "true" },
        static_options: [["Anonymous", "anonymous"]]
      ))

      assert_selector("[data-controller='admin-fetchable-multi-select-filter']")
      assert_selector("button[data-bs-toggle='dropdown']", text: /All/i)
      assert_selector("input[type='search']")
      assert_selector("turbo-frame")
      assert_selector("button[role='option']", text: "Anonymous")
    end

    it "uses custom param_name for hidden inputs" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"]
      ))

      assert_selector("input[name='account_ids[]'][value='1']", visible: :all)
    end

    it "includes search_url in data attributes for remote fetch" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        search_url_params: { only_with_votes: "true" },
        static_options: []
      ))

      assert_selector("[data-admin-fetchable-multi-select-filter-search-url-value*='account_select_options']")
    end

    it "renders clear button when request and selected_ids are present" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?account_ids[]=1&q=search")
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: req
      ))

      assert_selector("a.btn", text: I18n.t("admin.shared.clear_search"))
      clear_link = page.find("a.btn", text: I18n.t("admin.shared.clear_search"))
      assert_includes(clear_link["href"], "q=search")
      assert_not_includes(clear_link["href"], "account_ids")
    end

    it "does not render clear button when request is nil" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: nil
      ))

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end

    it "does not render clear button when selected_ids is empty" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?q=search")
      render_inline(described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: [],
        request: req
      ))

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end
  end

  describe "#show_clear_button?" do
    it "returns true when request and selected_ids are present" do
      req = build_request(url: "http://uppertown.test/admin/server_votes")
      component = described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: req
      )
      render_inline(component)

      assert(component.show_clear_button?)
    end

    it "returns false when request is nil" do
      component = described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: nil
      )
      render_inline(component)

      assert_not(component.show_clear_button?)
    end

    it "returns false when selected_ids is empty" do
      req = build_request(url: "http://uppertown.test/admin/server_votes")
      component = described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: [],
        request: req
      )
      render_inline(component)

      assert_not(component.show_clear_button?)
    end
  end

  describe "#clear_url" do
    it "returns url with param removed while preserving other params" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?account_ids[]=1&q=search&sort=name")
      component = described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: req
      )
      render_inline(component)

      clear_url = component.clear_url
      assert_includes(clear_url, "q=search")
      assert_includes(clear_url, "sort=name")
      assert_not_includes(clear_url, "account_ids")
    end

    it "returns nil when request is nil" do
      component = described_class.new(
        form: build_form,
        param_name: "account_ids",
        search_url: "/admin/account_select_options",
        static_options: [],
        selected_ids: ["1"],
        request: nil
      )
      render_inline(component)

      assert_nil(component.clear_url)
    end
  end
end
