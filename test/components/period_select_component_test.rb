require "test_helper"

class PeriodSelectComponentTest < ViewComponent::TestCase
  let(:described_class) { PeriodSelectComponent }
  let(:query_data) { [["Year", "year"], ["Month", "month"], ["Week", "week"]] }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("filter", nil, view_context, {})
  end

  def with_stubbed_query(data = query_data, &)
    query = -> { data }
    PeriodSelectOptionsQuery.stub(:new, -> do
      query
    end, &)
  end

  describe "rendering" do
    it "renders a select element for period" do
      with_stubbed_query do
        render_inline(described_class.new(build_form))
      end

      assert_selector("select.form-select[name='filter[period]'][data-controller='period-select']")
    end

    it "renders period options from the query" do
      with_stubbed_query do
        render_inline(described_class.new(build_form))
      end

      assert_selector("option[value='year']", text: "Year")
      assert_selector("option[value='month']", text: "Month")
      assert_selector("option[value='week']", text: "Week")
    end

    it "marks the selected value on the period option" do
      with_stubbed_query do
        render_inline(described_class.new(build_form, selected_value: "week"))
      end

      assert_selector("option[value='week'][selected]")
      assert_no_selector("option[value='year'][selected]")
      assert_no_selector("option[value='month'][selected]")
    end

    it "does not mark any option as selected when selected_value is nil" do
      with_stubbed_query do
        render_inline(described_class.new(build_form, selected_value: nil))
      end

      assert_no_selector("option[selected]")
    end
  end

  describe "#default_value" do
    it "defaults to Periods::MONTH" do
      with_stubbed_query do
        component = described_class.new(nil)

        assert_equal(Periods::MONTH, component.default_value)
      end
    end

    it "accepts a custom default_value" do
      with_stubbed_query do
        component = described_class.new(nil, default_value: Periods::WEEK)

        assert_equal(Periods::WEEK, component.default_value)
      end
    end
  end

  describe "#options" do
    it "delegates to the query" do
      query_data = [["Year", "year"], ["Month", "month"]]

      with_stubbed_query(query_data) do
        component = described_class.new(nil)

        assert_equal(query_data, component.options)
      end
    end

    it "memoizes the query result" do
      call_count = 0
      query = -> { call_count += 1; [] }

      PeriodSelectOptionsQuery.stub(:new, -> do
        query
      end) do
        component = described_class.new(nil)
        2.times { component.options }

        assert_equal(1, call_count)
      end
    end
  end
end
