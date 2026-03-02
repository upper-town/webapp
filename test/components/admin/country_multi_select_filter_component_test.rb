require "test_helper"

class Admin::CountryMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::CountryMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders country multi-select with All countries default" do
      CountrySelectOptionsQuery.stub(:call, [["🇺🇸 United States", "US"], ["🇩🇪 Germany", "DE"]]) do
        render_inline(described_class.new(form: build_form))
      end

      assert_selector("button[data-bs-toggle='dropdown']", text: /All countries/i)
      assert_selector("input[name='country_codes[]']", visible: :all, count: 0)
    end

    it "renders with selected countries" do
      CountrySelectOptionsQuery.stub(:call, [["🇺🇸 United States", "US"], ["🇩🇪 Germany", "DE"]]) do
        render_inline(described_class.new(form: build_form, selected_ids: %w[US DE]))
      end

      assert_selector("input[name='country_codes[]'][value='US']", visible: :all)
      assert_selector("input[name='country_codes[]'][value='DE']", visible: :all)
    end
  end
end
