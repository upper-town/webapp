require "test_helper"

class CountrySelectComponentTest < ViewComponent::TestCase
  let(:described_class) { CountrySelectComponent }
  let(:query_data) { [["🇺🇸 United States", "US"], ["🇧🇷 Brazil", "BR"]] }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("filter", nil, view_context, {})
  end

  def with_stubbed_query(data = query_data, &)
    query = -> { data }
    CountrySelectOptionsQuery.stub(:new, ->(**) do
      query
    end, &)
  end

  describe "rendering" do
    it "renders a select element for country_code" do
      with_stubbed_query do
        render_inline(described_class.new(build_form))
      end

      assert_selector("select.form-select[name='filter[country_code]'][data-controller='country-select']")
    end

    it "renders the default blank option" do
      with_stubbed_query do
        render_inline(described_class.new(build_form))
      end

      assert_selector("option[value='']", text: "All")
    end

    it "renders a custom blank option name" do
      with_stubbed_query do
        render_inline(described_class.new(build_form, blank_name: "Any"))
      end

      assert_selector("option[value='']", text: "Any")
    end

    it "renders country options from the query" do
      with_stubbed_query do
        render_inline(described_class.new(build_form))
      end

      assert_selector("option[value='US']", exact_text: "🇺🇸 United States")
      assert_selector("option[value='BR']", exact_text: "🇧🇷 Brazil")
    end

    it "marks the selected value on the country option" do
      with_stubbed_query do
        render_inline(described_class.new(build_form, selected_value: "BR"))
      end

      assert_selector("option[value='BR'][selected]")
      assert_no_selector("option[value='US'][selected]")
    end

    it "does not mark any option as selected when selected_value is nil" do
      with_stubbed_query do
        render_inline(described_class.new(build_form, selected_value: nil))
      end

      assert_no_selector("option[selected]")
    end
  end

  describe "#blank_option" do
    it "returns the default blank option pair" do
      with_stubbed_query do
        component = described_class.new(nil)

        assert_equal(["All", nil], component.blank_option)
      end
    end

    it "returns a custom blank option pair" do
      with_stubbed_query do
        component = described_class.new(nil, blank_name: "All countries")

        assert_equal(["All countries", nil], component.blank_option)
      end
    end
  end

  describe "#options" do
    it "delegates to the query" do
      query_data = [["🇺🇸 United States", "US"], ["🇨🇦 Canada", "CA"]]

      with_stubbed_query(query_data) do
        component = described_class.new(nil)

        assert_equal(query_data, component.options)
      end
    end

    it "memoizes the query result" do
      call_count = 0
      query = -> { call_count += 1; [] }

      CountrySelectOptionsQuery.stub(:new, ->(**) do
        query
      end) do
        component = described_class.new(nil)
        2.times { component.options }

        assert_equal(1, call_count)
      end
    end
  end

  describe "query initialization" do
    it "passes only_in_use and with_continents to the query" do
      received_kwargs = nil

      CountrySelectOptionsQuery.stub(:new, ->(**kwargs) do
        received_kwargs = kwargs
        -> { query_data }
      end) do
        described_class.new(nil, only_in_use: true, with_continents: true)
      end

      assert(received_kwargs[:only_in_use])
      assert(received_kwargs[:with_continents])
    end

    it "defaults only_in_use and with_continents to false" do
      received_kwargs = nil

      CountrySelectOptionsQuery.stub(:new, ->(**kwargs) do
        received_kwargs = kwargs
        -> { query_data }
      end) do
        described_class.new(nil)
      end

      assert_not(received_kwargs[:only_in_use])
      assert_not(received_kwargs[:with_continents])
    end
  end
end
