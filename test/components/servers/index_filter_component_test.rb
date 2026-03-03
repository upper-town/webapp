require "test_helper"

class Servers::IndexFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Servers::IndexFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders game multi-select, period select, and country multi-select" do
      render_inline(described_class.new(
        form: build_form,
        selected_value_game_ids: [1],
        selected_value_period: Periods::MONTH,
        selected_value_country_codes: ["US"]
      ))

      assert_selector(".servers-index-filter-game")
      assert_selector(".servers-index-filter-period-country")
      assert_text(Server.human_attribute_name(:game_id))
      assert_text(ServerStat.human_attribute_name(:period))
      assert_text(Server.human_attribute_name(:country_code))
    end

    it "renders with default period when not specified" do
      render_inline(described_class.new(form: build_form))

      assert_selector(".servers-index-filter")
    end
  end

  describe "attr_readers" do
    it "exposes form, selected_value_game_ids, selected_value_period, selected_value_country_codes" do
      form = build_form
      component = described_class.new(
        form:,
        selected_value_game_ids: [1, 2],
        selected_value_period: Periods::YEAR,
        selected_value_country_codes: ["US", "BR"]
      )

      assert_equal(form, component.form)
      assert_equal(["1", "2"], component.selected_value_game_ids)
      assert_equal(Periods::YEAR, component.selected_value_period)
      assert_equal(["US", "BR"], component.selected_value_country_codes)
    end

    it "normalizes selected_value_game_ids via normalize_ids" do
      component = described_class.new(
        form: build_form,
        selected_value_game_ids: [1, 2]
      )

      assert_equal(["1", "2"], component.selected_value_game_ids)
    end

    it "normalizes selected_value_country_codes" do
      component = described_class.new(
        form: build_form,
        selected_value_country_codes: ["US", "BR"]
      )

      assert_equal(["US", "BR"], component.selected_value_country_codes)
    end
  end
end
