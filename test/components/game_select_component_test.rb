# frozen_string_literal: true

require "test_helper"

class GameSelectComponentTest < ViewComponent::TestCase
  let(:query_data) { [["Minecraft", 1], ["Rust", 2]] }

  def build_form
    view_context = ApplicationController.new.view_context
    ActionView::Helpers::FormBuilder.new("filter", nil, view_context, {})
  end

  def with_stubbed_query(data = query_data, &)
    query = -> { data }
    GameSelectOptionsQuery.stub(:new, ->(**) do
      query
    end, &)
  end

  describe "rendering" do
    it "renders a select element for game_id" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form))
      end

      assert_selector("select.form-select[name='filter[game_id]'][data-controller='game-select']")
    end

    it "renders the default blank option" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form))
      end

      assert_selector("option[value='']", text: "All")
    end

    it "renders a custom blank option name" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form, blank_name: "Any"))
      end

      assert_selector("option[value='']", text: "Any")
    end

    it "renders game options from the query" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form))
      end

      assert_selector("option[value='1']", text: "Minecraft")
      assert_selector("option[value='2']", text: "Rust")
    end

    it "marks the selected value on the game option" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form, selected_value: 2))
      end

      assert_selector("option[value='2'][selected]")
      assert_no_selector("option[value='1'][selected]")
    end

    it "does not mark any option as selected when selected_value is nil" do
      with_stubbed_query do
        render_inline(GameSelectComponent.new(build_form, selected_value: nil))
      end

      assert_no_selector("option[selected]")
    end

    it "exposes default_value as a readable attribute" do
      with_stubbed_query do
        component = GameSelectComponent.new(build_form, default_value: 1)

        assert_equal(1, component.default_value)
      end
    end
  end

  describe "#blank_option" do
    it "returns the default blank option pair" do
      with_stubbed_query do
        component = GameSelectComponent.new(nil)

        assert_equal(["All", nil], component.blank_option)
      end
    end

    it "returns a custom blank option pair" do
      with_stubbed_query do
        component = GameSelectComponent.new(nil, blank_name: "All games")

        assert_equal(["All games", nil], component.blank_option)
      end
    end
  end

  describe "#options" do
    it "delegates to the query" do
      query_data = [["Minecraft", 1], ["Terraria", 3]]

      with_stubbed_query(query_data) do
        component = GameSelectComponent.new(nil)

        assert_equal(query_data, component.options)
      end
    end

    it "memoizes the query result" do
      call_count = 0
      query = -> { call_count += 1; [] }

      GameSelectOptionsQuery.stub(:new, ->(**) do
        query
      end) do
        component = GameSelectComponent.new(nil)
        2.times { component.options }

        assert_equal(1, call_count)
      end
    end
  end

  describe "query initialization" do
    it "passes only_in_use to the query" do
      received_kwargs = nil

      GameSelectOptionsQuery.stub(:new, ->(**kwargs) do
        received_kwargs = kwargs
        -> { query_data }
      end) do
        GameSelectComponent.new(nil, only_in_use: true)
      end

      assert(received_kwargs[:only_in_use])
    end

    it "defaults only_in_use to false" do
      received_kwargs = nil

      GameSelectOptionsQuery.stub(:new, ->(**kwargs) do
        received_kwargs = kwargs
        -> { query_data }
      end) do
        GameSelectComponent.new(nil)
      end

      assert_not(received_kwargs[:only_in_use])
    end
  end
end
