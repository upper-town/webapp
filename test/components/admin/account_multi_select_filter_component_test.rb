require "test_helper"

class Admin::AccountMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::AccountMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders account multi-select with All accounts default" do
      render_inline(described_class.new(form: build_form))

      assert_selector("button[data-bs-toggle='dropdown']", text: /All accounts/i)
      assert_selector("input[name='account_ids[]']", visible: :all, count: 0)
      assert_selector("[data-admin-fetchable-multi-select-filter-search-url-value]", text: nil)
    end

    it "renders with selected accounts" do
      render_inline(described_class.new(form: build_form, selected_ids: ["1"]))

      assert_selector("input[name='account_ids[]'][value='1']", visible: :all)
    end

    it "includes Anonymous as static option" do
      render_inline(described_class.new(form: build_form))

      assert_selector("button[data-name='Anonymous']", text: "Anonymous")
    end

    it "renders with Anonymous selected" do
      render_inline(described_class.new(form: build_form, selected_ids: [Admin::ServerVotesQuery::ANONYMOUS_VALUE]))

      assert_selector("input[name='account_ids[]'][value='anonymous']", visible: :all)
    end

    it "includes remote search URL for scalable account loading" do
      result = render_inline(described_class.new(form: build_form))

      assert_includes(result.to_s, "account_select_options")
    end

    it "renders search input outside turbo-frame and options inside frame for remote search" do
      render_inline(described_class.new(form: build_form))

      assert_selector("turbo-frame#admin_fetchable_multi_select_filter_options_account_ids")
      assert_selector("[data-admin-fetchable-multi-select-filter-target='searchInput']")
      assert_selector("[data-admin-fetchable-multi-select-filter-target='optionsFrame']")
    end
  end
end
