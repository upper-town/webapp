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

    it "renders continent options when with_continents is used" do
      options_with_continent = [
        ["North America", "US,CA,MX", { class: "fw-bold" }],
        ["🇺🇸 United States", "US"],
        ["🇨🇦 Canada", "CA"],
        ["🇩🇪 Germany", "DE"]
      ]
      CountrySelectOptionsQuery.stub(:call, options_with_continent) do
        render_inline(described_class.new(form: build_form))
      end

      assert_selector("button[data-id='US,CA,MX']", text: "North America")
      assert_selector("button[data-id='US,CA,MX'].fw-bold")
      assert_selector("button[data-id='US']", text: /United States/)
    end

    it "shows continent as checked when all constituent countries are selected" do
      options_with_continent = [
        ["North America", "US,CA,MX", { class: "fw-bold" }],
        ["🇺🇸 United States", "US"],
        ["🇨🇦 Canada", "CA"],
        ["🇩🇪 Germany", "DE"]
      ]
      CountrySelectOptionsQuery.stub(:call, options_with_continent) do
        render_inline(described_class.new(form: build_form, selected_ids: %w[US CA MX]))
      end

      continent_checkbox = page.find("button[data-id='US,CA,MX'] input[type='checkbox']")
      assert(continent_checkbox["checked"])
    end
  end
end
