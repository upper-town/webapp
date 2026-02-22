# frozen_string_literal: true

require "test_helper"

class PaginationCursorComponentTest < ViewComponent::TestCase
  let(:described_class) { PaginationCursorComponent }
  let(:url) { "http://uppertown.test/servers" }

  def create_dummies(count = 10)
    count.times.map { create_dummy }
  end

  def build_pagination_cursor(per_page: 3, order: "asc", indicator: "after", cursor: nil)
    PaginationCursor.new(
      Dummy.order(:id),
      build_request(url:),
      per_page:, order:, indicator:, cursor:
    )
  end

  describe "#initialize" do
    it "stores the pagination_cursor object" do
      create_dummies
      pagination_cursor = build_pagination_cursor
      component = described_class.new(pagination_cursor)

      assert_same(pagination_cursor, component.pagination_cursor)
    end

    it "applies default options" do
      create_dummies
      component = described_class.new(build_pagination_cursor)

      assert(component.options[:show_first])
      assert_not(component.options[:show_goto])
    end

    it "merges custom options with defaults" do
      create_dummies
      component = described_class.new(build_pagination_cursor, show_first: false, show_goto: true)

      assert_not(component.options[:show_first])
      assert(component.options[:show_goto])
    end
  end

  describe "show predicates" do
    it "returns show_first? from options" do
      assert(described_class.new(nil, show_first: true).show_first?)
      assert_not(described_class.new(nil, show_first: false).show_first?)
    end

    it "returns show_goto? from options" do
      assert(described_class.new(nil, show_goto: true).show_goto?)
      assert_not(described_class.new(nil, show_goto: false).show_goto?)
    end

    it "returns show_total_pages? from options" do
      assert(described_class.new(nil, show_total_pages: true).show_total_pages?)
      assert_not(described_class.new(nil, show_total_pages: false).show_total_pages?)
    end

    it "returns show_per_page? from options" do
      assert(described_class.new(nil, show_per_page: true).show_per_page?)
      assert_not(described_class.new(nil, show_per_page: false).show_per_page?)
    end

    it "returns show_total_count? from options" do
      assert(described_class.new(nil, show_total_count: true).show_total_count?)
      assert_not(described_class.new(nil, show_total_count: false).show_total_count?)
    end
  end

  describe "#show_badges?" do
    it "returns true when any badge option is enabled, false otherwise" do
      assert(described_class.new(nil, show_total_pages: true).show_badges?)
      assert(described_class.new(nil, show_per_page: true).show_badges?)
      assert(described_class.new(nil, show_total_count: true).show_badges?)
      assert_not(described_class.new(nil).show_badges?)
    end
  end

  describe "icon accessors" do
    it "returns default icon values" do
      component = described_class.new(nil)

      assert_equal("First", component.first_icon)
      assert_equal("Prev", component.prev_icon)
      assert_equal("Next", component.next_icon)
      assert_equal("Go", component.go_icon)
    end

    it "returns custom icon values" do
      component = described_class.new(nil,
        first_icon: "<<",
        prev_icon: "<",
        next_icon: ">",
        go_icon: "Jump")

      assert_equal("<<", component.first_icon)
      assert_equal("<", component.prev_icon)
      assert_equal(">", component.next_icon)
      assert_equal("Jump", component.go_icon)
    end
  end

  describe "rendering prev/next navigation" do
    it "renders enabled prev and next links on a middle page" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id)
      render_inline(described_class.new(pagination_cursor))

      assert_selector(".pagination-cursor-prev-next a.page-link", text: "Prev")
      assert_selector(".pagination-cursor-prev-next a.page-link", text: "Next")
    end

    it "renders disabled prev when there is no before cursor" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor))

      assert_selector(".pagination-cursor-prev-next .page-item.disabled span.page-link", text: "Prev")
      assert_no_selector(".pagination-cursor-prev-next a.page-link", text: "Prev")
    end

    it "renders disabled next when there is no after cursor" do
      create_dummies(3)
      pagination_cursor = build_pagination_cursor(per_page: 5)
      render_inline(described_class.new(pagination_cursor))

      assert_selector(".pagination-cursor-prev-next .page-item.disabled span.page-link", text: "Next")
      assert_no_selector(".pagination-cursor-prev-next a.page-link", text: "Next")
    end

    it "renders custom prev and next icons" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id)
      render_inline(described_class.new(pagination_cursor, prev_icon: "<", next_icon: ">"))

      assert_selector(".pagination-cursor-prev-next a.page-link", text: "<")
      assert_selector(".pagination-cursor-prev-next a.page-link", text: ">")
    end

    it "renders all navigation as disabled when there are no records" do
      pagination_cursor = PaginationCursor.new(
        Dummy.order(:id),
        build_request(url:),
        per_page: 3, total_count: 0
      )
      render_inline(described_class.new(pagination_cursor))

      assert_selector(".page-item.disabled span.page-link", text: "First")
      assert_selector(".pagination-cursor-prev-next .page-item.disabled span.page-link", text: "Prev")
      assert_selector(".pagination-cursor-prev-next .page-item.disabled span.page-link", text: "Next")
    end
  end

  describe "rendering first button" do
    it "renders enabled first link when not at start cursor" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id)
      render_inline(described_class.new(pagination_cursor))

      assert_selector("a.page-link", text: "First")
    end

    it "renders disabled first button at start cursor" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor))

      assert_selector(".page-item.disabled span.page-link", text: "First")
      assert_no_selector("a.page-link", text: "First")
    end

    it "hides the first button when show_first is false" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor, show_first: false))

      assert_no_selector(".page-link", text: "First")
    end

    it "renders custom first icon" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id)
      render_inline(described_class.new(pagination_cursor, first_icon: "<<"))

      assert_selector("a.page-link", text: "<<")
    end
  end

  describe "rendering goto form" do
    it "hides the goto form by default" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor))

      assert_no_selector(".pagination-cursor-goto")
    end

    it "renders the goto form when show_goto is true" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id, indicator: "before")
      render_inline(described_class.new(pagination_cursor, show_goto: true))

      assert_selector(".pagination-cursor-goto")
      assert_selector("select[name='indicator'] option[selected][value='before']")
      assert_selector("input[name='cursor']")
      assert_selector("select[name='order']")
      assert_selector("button[type='submit']", text: "Go")
    end

    it "selects the current indicator value" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id, indicator: "after")
      render_inline(described_class.new(pagination_cursor, show_goto: true))

      assert_selector("select[name='indicator'] option[selected][value='after']")
    end

    it "selects the current order value" do
      dummies = create_dummies
      pagination_cursor = build_pagination_cursor(cursor: dummies[2].id, order: "desc")
      render_inline(described_class.new(pagination_cursor, show_goto: true))

      assert_selector("select[name='order'] option[selected][value='desc']")
    end

    it "renders custom go icon" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor, show_goto: true, go_icon: "Jump"))

      assert_selector("button[type='submit']", text: "Jump")
    end
  end

  describe "rendering badges" do
    it "does not render badges by default" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor))

      assert_no_selector(".badge")
    end

    it "renders total_pages badge when show_total_pages is enabled" do
      create_dummies(10)
      pagination_cursor = build_pagination_cursor(per_page: 3)
      render_inline(described_class.new(pagination_cursor, show_total_pages: true))

      assert_selector(".badge", text: /total_pages 4/)
    end

    it "renders per_page badge when show_per_page is enabled" do
      create_dummies
      render_inline(described_class.new(build_pagination_cursor(per_page: 5), show_per_page: true))

      assert_selector(".badge", text: /per_page 5/)
    end

    it "renders total_count badge when show_total_count is enabled" do
      create_dummies(10)
      pagination_cursor = build_pagination_cursor
      render_inline(described_class.new(pagination_cursor, show_total_count: true))

      assert_selector(".badge", text: /total_count 10/)
    end
  end
end
