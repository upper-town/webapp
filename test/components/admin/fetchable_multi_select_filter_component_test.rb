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
  end
end
