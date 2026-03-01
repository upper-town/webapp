require "test_helper"

class Admin::GameMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::GameMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders game multi-select with All games default" do
      GameSelectOptionsQuery.stub(:call, [["Minecraft", 1]]) do
        render_inline(described_class.new(form: build_form))
      end

      assert_selector("button[data-bs-toggle='dropdown']", text: /All games/i)
      assert_selector("input[name='game_ids[]']", visible: :all, count: 0)
    end

    it "renders with selected games" do
      GameSelectOptionsQuery.stub(:call, [["Minecraft", 1], ["PWI", 2]]) do
        render_inline(described_class.new(form: build_form, selected_ids: ["1"]))
      end

      assert_selector("input[name='game_ids[]'][value='1']", visible: :all)
    end
  end
end
