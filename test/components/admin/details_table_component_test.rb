require "test_helper"

class Admin::DetailsTableComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::DetailsTableComponent }

  describe "rendering" do
    it "renders empty when no sections" do
      render_inline(described_class.new(sections: []))

      assert_selector("table.admin-details-table")
      assert_no_selector("tr.table-light")
    end

    it "renders section titles and key-value rows" do
      sections = [
        {
          title: "Basic Info",
          rows: [
            ["Name", "Test Server"],
            ["ID", 123]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("th", text: "Basic Info")
      assert_selector("th", text: "Name")
      assert_selector("td", text: "Test Server")
      assert_selector("th", text: "ID")
      assert_selector("td", text: "123")
    end

    it "renders proc values by calling them" do
      sections = [
        {
          title: "Dynamic",
          rows: [
            ["Computed", -> { "computed-value" }]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("td", text: "computed-value")
    end

    it "renders full-width rows" do
      sections = [
        {
          title: "Section",
          rows: [
            ["Full width content"]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("td[colspan='2']", text: "Full width content")
    end

    it "renders copy button when copyable option is true" do
      sections = [
        {
          title: "Copyable",
          rows: [
            ["Token", "abc123", { copyable: true }]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("[data-controller='copy-to-clipboard']")
      assert_selector("button[data-copy-btn]")
      assert_selector("i.bi-clipboard")
    end

    it "renders copy button with custom copyable proc" do
      sections = [
        {
          title: "Copyable",
          rows: [
            ["Label", -> { "display" }, { copyable: -> { "copy-value" } }]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("[data-controller='copy-to-clipboard']")
      assert_selector("[data-copy-to-clipboard-value='copy-value']")
    end

    it "omits copy button when copyable value is blank" do
      sections = [
        {
          title: "Copyable",
          rows: [
            ["Empty", nil, { copyable: true }]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_no_selector("button[data-copy-btn]")
    end

    it "renders nil and empty string as blank" do
      sections = [
        {
          title: "Blanks",
          rows: [
            ["Nil", nil],
            ["Empty", ""]
          ]
        }
      ]

      render_inline(described_class.new(sections:))

      assert_selector("th", text: "Nil")
      assert_selector("th", text: "Empty")
    end
  end

  describe "#row_value" do
    it "returns nil for nil" do
      component = described_class.new(sections: [])

      assert_nil(component.row_value(nil))
    end

    it "returns nil for empty string" do
      component = described_class.new(sections: [])

      assert_nil(component.row_value(""))
    end

    it "calls proc and returns result" do
      component = described_class.new(sections: [])

      assert_equal("proc-result", component.row_value(-> { "proc-result" }))
    end

    it "returns value as-is for other types" do
      component = described_class.new(sections: [])

      assert_equal("text", component.row_value("text"))
      assert_equal(42, component.row_value(42))
    end
  end

  describe "#key_value_row?" do
    it "returns true for array with 2+ elements" do
      component = described_class.new(sections: [])

      assert(component.key_value_row?(["a", "b"]))
      assert(component.key_value_row?(["a", "b", {}]))
    end

    it "returns false for array with 1 element" do
      component = described_class.new(sections: [])

      assert_not(component.key_value_row?(["a"]))
    end

    it "returns false for non-array" do
      component = described_class.new(sections: [])

      assert_not(component.key_value_row?("string"))
    end
  end

  describe "#full_width_row?" do
    it "returns true for array with 1 element" do
      component = described_class.new(sections: [])

      assert(component.full_width_row?(["content"]))
    end

    it "returns false for array with 2+ elements" do
      component = described_class.new(sections: [])

      assert_not(component.full_width_row?(["a", "b"]))
    end
  end
end
