require "test_helper"

class Admin::UsersFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::UsersFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders filter with date range and date column options" do
      render_inline(described_class.new(
        form: build_form,
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        date_column: "created_at"
      ))

      assert_selector("input[type=date][name=start_date][value='2024-01-15']")
      assert_selector("input[type=date][name=end_date][value='2024-01-20']")
      assert_selector("select[name=date_column]")
    end

    it "renders time inputs and timezone select" do
      render_inline(described_class.new(form: build_form))

      assert_selector("input[type=time][name=start_time]")
      assert_selector("input[type=time][name=end_time]")
      assert_selector("select[name=time_zone]")
    end
  end

  describe "#date_column_options" do
    it "returns options for created_at, updated_at, email_confirmed_at, locked_at" do
      component = described_class.new(form: build_form)
      options = component.date_column_options

      assert_equal(4, options.size)
      assert(options.any? { |_label, value| value == "created_at" })
      assert(options.any? { |_label, value| value == "updated_at" })
      assert(options.any? { |_label, value| value == "email_confirmed_at" })
      assert(options.any? { |_label, value| value == "locked_at" })
    end
  end

  describe "#has_active_filters?" do
    it "returns true when start_date is present" do
      component = described_class.new(form: build_form, start_date: "2024-01-15")

      assert component.has_active_filters?
    end

    it "returns true when end_date is present" do
      component = described_class.new(form: build_form, end_date: "2024-01-20")

      assert component.has_active_filters?
    end

    it "returns true when time_zone_param_present is true" do
      component = described_class.new(form: build_form, time_zone_param_present: true)

      assert component.has_active_filters?
    end

    it "returns false when no filter params are set" do
      component = described_class.new(form: build_form)

      assert_not component.has_active_filters?
    end
  end
end
