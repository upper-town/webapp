require "test_helper"

class MultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { MultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders multi-select with data attributes for Stimulus controller" do
      render_inline(
        described_class.new(
          form: build_form,
          param_name: "game_ids",
          options: [["Minecraft", 1]],
          selected_ids: []
        )
      )

      assert_selector("[data-controller='multi-select-filter']")
      assert_selector("[data-multi-select-filter-param-name-value='game_ids']")
      assert_selector("button[data-bs-toggle='dropdown']")
    end
  end
end
