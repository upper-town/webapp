require "test_helper"

class Admin::DateRangeFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::DateRangeFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders date inputs with default param names" do
      render_inline(described_class.new(form: build_form))

      assert_selector("input[type=date][name=start_date]")
      assert_selector("input[type=date][name=end_date]")
    end

    it "renders date inputs with prefixed param names when param_prefix is set" do
      render_inline(described_class.new(form: build_form, param_prefix: "created_at"))

      assert_selector("input[type=date][name=created_at_start_date]")
      assert_selector("input[type=date][name=created_at_end_date]")
    end

    it "renders with start_date and end_date values" do
      render_inline(described_class.new(
        form: build_form,
        start_date: "2024-01-15",
        end_date: "2024-01-20"
      ))

      assert_selector("input[name=start_date][value='2024-01-15']")
      assert_selector("input[name=end_date][value='2024-01-20']")
    end

    it "renders timezone select when show_time_zone is true" do
      render_inline(described_class.new(
        form: build_form,
        show_time_zone: true,
        time_zone: "America/New_York"
      ))

      assert_selector("select[name=time_zone]")
      assert_text("Timezone")
    end

    it "does not render timezone select when show_time_zone is false" do
      render_inline(described_class.new(form: build_form, show_time_zone: false))

      assert_no_selector("select[name=time_zone]")
    end

    it "renders time inputs when show_time is true" do
      render_inline(described_class.new(form: build_form, show_time: true))

      assert_selector("input[type=time][name=start_time][step=1]")
      assert_selector("input[type=time][name=end_time][step=1]")
    end

    it "does not render time inputs when show_time is false" do
      render_inline(described_class.new(form: build_form, show_time: false))

      assert_no_selector("input[name=start_time]")
      assert_no_selector("input[name=end_time]")
    end

    it "renders time inputs with prefixed param names when param_prefix and show_time are set" do
      render_inline(described_class.new(form: build_form, show_time: true, param_prefix: "created_at"))

      assert_selector("input[name=created_at_start_time]")
      assert_selector("input[name=created_at_end_time]")
    end

    it "renders timezone select with prefixed param when param_prefix is set" do
      render_inline(described_class.new(
        form: build_form,
        show_time_zone: true,
        param_prefix: "created_at"
      ))

      assert_selector("select[name=created_at_time_zone]")
    end

    it "renders date_column select when show_date_column is true" do
      render_inline(described_class.new(
        form: build_form,
        show_date_column: true,
        date_column: "created_at",
        date_column_options: [["Created at", "created_at"], ["Updated at", "updated_at"]]
      ))

      assert_selector("select[name=date_column]")
    end

    it "does not render date_column select when show_date_column is false" do
      render_inline(described_class.new(form: build_form, show_date_column: false))

      assert_no_selector("select[name=date_column]")
    end
  end

  describe "#trigger_text" do
    it "shows both dates when start_date and end_date are present" do
      render_inline(described_class.new(
        form: build_form,
        start_date: "2024-01-15",
        end_date: "2024-01-20"
      ))

      assert_text("2024-01-15 – 2024-01-20")
    end

    it "shows 'From' prefix when only start_date is present" do
      render_inline(described_class.new(
        form: build_form,
        start_date: "2024-01-15"
      ))

      assert_text("From 2024-01-15")
    end

    it "shows 'To' prefix when only end_date is present" do
      render_inline(described_class.new(
        form: build_form,
        end_date: "2024-01-20"
      ))

      assert_text("To 2024-01-20")
    end

    it "shows 'All dates' when neither date is present" do
      render_inline(described_class.new(form: build_form))

      assert_text("All dates")
    end

    it "includes time in trigger_text when show_time and times are present" do
      render_inline(described_class.new(
        form: build_form,
        show_time: true,
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        start_time: "09:00:00",
        end_time: "17:30:00"
      ))

      assert_text("2024-01-15")
      assert_text("2024-01-20")
      assert_text("09:00:00")
      assert_text("17:30:00")
    end
  end

  describe "#show_clear_button?" do
    it "returns true when request is present and dates are set" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?start_date=2024-01-15")
      component = described_class.new(form: build_form, start_date: "2024-01-15", request: req)

      assert component.show_clear_button?
    end

    it "returns true when show_time_zone and time_zone_param_present and timezone differs from browser" do
      req = build_request(
        url: "http://uppertown.test/admin/server_votes?time_zone=America/New_York",
        headers: { "HTTP_COOKIE" => "browser_time_zone=America/Los_Angeles" }
      )
      component = described_class.new(
        form: build_form,
        show_time_zone: true,
        time_zone_param_present: true,
        time_zone: "America/New_York",
        request: req
      )

      assert component.show_clear_button?
    end

    it "returns false when show_time_zone and time_zone_param_present but timezone matches browser" do
      req = build_request(
        url: "http://uppertown.test/admin/server_votes?time_zone=America/New_York",
        headers: { "HTTP_COOKIE" => "browser_time_zone=America/New_York" }
      )
      component = described_class.new(
        form: build_form,
        show_time_zone: true,
        time_zone_param_present: true,
        time_zone: "America/New_York",
        request: req
      )

      assert_not component.show_clear_button?
    end

    it "returns false when request is nil" do
      component = described_class.new(form: build_form, start_date: "2024-01-15", request: nil)

      assert_not component.show_clear_button?
    end

    it "returns false when no dates are set and no time_zone param" do
      req = build_request(url: "http://uppertown.test/admin/server_votes")
      component = described_class.new(form: build_form, request: req)

      assert_not component.show_clear_button?
    end
  end

  describe "#clear_url" do
    it "removes start_date and end_date from the URL while preserving other params" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?start_date=2024-01-15&end_date=2024-01-20&game_ids[]=1")
      component = described_class.new(
        form: build_form,
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        request: req
      )

      url = component.clear_url

      assert_includes(url, "game_ids")
      assert_not_includes(url, "start_date")
      assert_not_includes(url, "end_date")
    end

    it "removes time_zone from the URL when show_time_zone is true" do
      req = build_request(url: "http://uppertown.test/admin/server_votes?start_date=2024-01-15&time_zone=America/New_York&game_ids[]=1")
      component = described_class.new(
        form: build_form,
        start_date: "2024-01-15",
        show_time_zone: true,
        request: req
      )

      url = component.clear_url

      assert_includes(url, "game_ids")
      assert_not_includes(url, "time_zone")
    end
  end
end
