require "test_helper"

class Admin::ServersFilterComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServersFilterComponent }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("", nil, view_context, {})
  end

  def with_stubbed_country_query(data = [["🇺🇸 United States", "US"]])
    CountrySelectOptionsQuery.stub(:call, data) { yield }
  end

  def with_stubbed_game_options(data = [["Minecraft", 1], ["PWI", 2]])
    GameSelectOptionsQuery.stub(:call, data) { yield }
  end

  describe "rendering" do
    it "renders status, game multi-select, and country selects" do
      with_stubbed_country_query do
        with_stubbed_game_options do
          render_inline(described_class.new(form: build_form))
        end
      end

      assert_selector("button[aria-label='Status']", text: /All statuses/i)
      assert_selector("button[data-bs-toggle='dropdown']", text: /All games/i)
      assert_selector("button[aria-label='Country']", text: /All countries/i)
    end

    it "omits game multi-select when hide_game_filter is true" do
      with_stubbed_country_query do
        render_inline(described_class.new(form: build_form, hide_game_filter: true))
      end

      assert_selector("button[aria-label='Status']", text: /All statuses/i)
      assert_no_selector("button[data-bs-toggle='dropdown']", text: /All games/i)
      assert_selector("button[aria-label='Country']", text: /All countries/i)
    end

    it "shows clear button when filters are active" do
      with_stubbed_country_query([]) do
        with_stubbed_game_options([]) do
          render_inline(described_class.new(
            form: build_form,
            selected_status_ids: ["verified"]
          ))
        end
      end

      assert_selector("a.btn", text: "Clear")
    end

    it "includes hidden fields for q, sort, sort_dir when present in request" do
      req = build_request(url: "http://uppertown.test/admin/servers?q=my+search&sort=name&sort_dir=asc")
      with_stubbed_country_query([]) do
        with_stubbed_game_options([]) do
          render_inline(described_class.new(
            form: build_form,
            request: req
          ))
        end
      end

      assert_selector("input[type='hidden'][name='q']", visible: :all)
      input = page.find("input[name='q']", visible: :all)
      assert_equal("my search", input.value)
    end
  end

  describe "#has_active_filters?" do
    it "returns true when status is present" do
      component = described_class.new(form: build_form, selected_status_ids: ["verified"])

      assert(component.has_active_filters?)
    end

    it "returns true when country_codes is present" do
      component = described_class.new(form: build_form, selected_country_codes: ["US"])

      assert(component.has_active_filters?)
    end

    it "returns true when game_ids is present" do
      component = described_class.new(form: build_form, selected_game_ids: ["1"])

      assert(component.has_active_filters?)
    end

    it "returns false when game_ids is present but hide_game_filter is true" do
      component = described_class.new(
        form: build_form,
        selected_game_ids: ["1"],
        hide_game_filter: true
      )

      assert_not(component.has_active_filters?)
    end

    it "returns false when no filters are set" do
      component = described_class.new(form: build_form)

      assert_not(component.has_active_filters?)
    end
  end
end
