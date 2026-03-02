require "test_helper"

class Admin::PeriodMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::PeriodMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders period multi-select with All periods default" do
      render_inline(described_class.new(form: build_form))

      assert_selector("button[data-bs-toggle='dropdown']", text: /All periods/i)
      assert_selector("input[name='periods[]']", visible: :all, count: 0)
    end

    it "renders with selected periods" do
      render_inline(described_class.new(form: build_form, selected_ids: %w[month week]))

      assert_selector("input[name='periods[]'][value='month']", visible: :all)
      assert_selector("input[name='periods[]'][value='week']", visible: :all)
    end
  end
end
