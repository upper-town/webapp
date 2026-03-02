require "test_helper"

class Admin::StatusMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::StatusMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders status multi-select with All statuses default" do
      render_inline(described_class.new(form: build_form))

      assert_selector("button[data-bs-toggle='dropdown']", text: /All statuses/i)
      assert_selector("input[name='status[]']", visible: :all, count: 0)
    end

    it "renders with selected statuses" do
      render_inline(described_class.new(form: build_form, selected_ids: %w[verified archived]))

      assert_selector("input[name='status[]'][value='verified']", visible: :all)
      assert_selector("input[name='status[]'][value='archived']", visible: :all)
    end
  end
end
