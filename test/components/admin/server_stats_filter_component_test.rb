require "test_helper"

class Admin::ServerStatsFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServerStatsFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders period select" do
      render_inline(described_class.new(form: build_form))

      assert_selector("select[name='period']")
      assert_selector("select[name='period'][aria-label='#{I18n.t('admin.server_stats.index.filter.period')}']")
    end

    it "shows clear button when period filter is active" do
      render_inline(described_class.new(
        form: build_form,
        selected_value_period: "month"
      ))

      assert_selector("a.btn", text: "Clear")
    end

    it "includes hidden fields for q, sort, sort_dir when present in request" do
      req = build_request(url: "http://uppertown.test/admin/server_stats?q=my+search&sort=period&sort_dir=asc")
      render_inline(described_class.new(
        form: build_form,
        request: req
      ))

      assert_selector("input[type='hidden'][name='q']", visible: :all)
      input = page.find("input[name='q']", visible: :all)
      assert_equal("my search", input.value)
    end
  end

  describe "#has_active_filters?" do
    it "returns true when period is present" do
      component = described_class.new(form: build_form, selected_value_period: "month")

      assert(component.has_active_filters?)
    end

    it "returns false when no filters are set" do
      component = described_class.new(form: build_form)

      assert_not(component.has_active_filters?)
    end
  end
end
