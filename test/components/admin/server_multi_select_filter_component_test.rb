require "test_helper"

class Admin::ServerMultiSelectFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServerMultiSelectFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders server multi-select with All servers default" do
      ServerSelectOptionsQuery.stub(:call, [["Cool Server", 1]]) do
        render_inline(described_class.new(form: build_form))
      end

      assert_selector("button[data-bs-toggle='dropdown']", text: /All servers/i)
      assert_selector("input[name='server_ids[]']", visible: :all, count: 0)
    end

    it "renders with selected servers" do
      ServerSelectOptionsQuery.stub(:call, [["Cool Server", 1]]) do
        render_inline(described_class.new(form: build_form, selected_ids: ["1"]))
      end

      assert_selector("input[name='server_ids[]'][value='1']", visible: :all)
    end
  end
end
