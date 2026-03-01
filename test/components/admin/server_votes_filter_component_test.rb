require "test_helper"

class Admin::ServerVotesFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServerVotesFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  describe "rendering" do
    it "renders game, server, and account multi-select filters" do
      GameSelectOptionsQuery.stub(:call, []) do
        ServerSelectOptionsQuery.stub(:call, []) do
          render_inline(described_class.new(form: build_form))
        end
      end

      assert_selector("[data-admin-multi-select-filter-param-name-value='game_ids']")
      assert_selector("[data-admin-multi-select-filter-param-name-value='server_ids']")
      assert_selector("[data-admin-fetchable-multi-select-filter-param-name-value='account_ids']")
    end

    it "has_active_filters? returns true when any filter is selected" do
      component = described_class.new(
        form: build_form,
        selected_game_ids: ["1"]
      )

      assert component.has_active_filters?
    end

    it "has_active_filters? returns false when no filter is selected" do
      component = described_class.new(form: build_form)

      assert_not component.has_active_filters?
    end

    it "has_active_filters? returns true when anonymous is selected in account_ids" do
      component = described_class.new(
        form: build_form,
        selected_account_ids: [Admin::ServerVotesQuery::ANONYMOUS_VALUE]
      )

      assert component.has_active_filters?
    end
  end
end
