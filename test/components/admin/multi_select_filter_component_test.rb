require "test_helper"

class Admin::MultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::MultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders dropdown with options and apply button" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "game_ids",
        options: [["Minecraft", 1], ["PWI", 2]]
      ))

      assert_selector("[data-controller='admin-multi-select-filter']")
      assert_selector("button[data-bs-toggle='dropdown']", text: /All/i)
      assert_selector("input[type='search']")
      assert_selector("button.btn-outline-primary", text: "Apply")
      assert_selector("button[role='option']", text: "Minecraft")
      assert_selector("button[role='option']", text: "PWI")
    end

    it "uses custom param_name for hidden inputs" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "country_codes",
        options: [["US", "US"]],
        selected_ids: ["US"]
      ))

      assert_selector("input[name='country_codes[]'][value='US']", visible: :all)
    end

    it "shows selected option names in trigger when 1 selected" do
      render_inline(described_class.new(
        form: build_form,
        param_name: "ids",
        options: [["Alpha", 1], ["Beta", 2]],
        selected_ids: ["1"]
      ))

      assert_selector("button[data-bs-toggle='dropdown']", text: "Alpha")
    end
  end
end
