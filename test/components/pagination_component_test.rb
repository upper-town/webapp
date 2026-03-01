require "test_helper"

class PaginationComponentTest < ViewComponent::TestCase
  let(:described_class) { PaginationComponent }
  let(:url) { "http://uppertown.test/servers" }

  def build_pagination(record_count: 10, per_page: 3, page: 2, total_count: nil)
    record_count.times { create_dummy }
    Pagination.new(
      Dummy.order(:id),
      build_request(url:),
      page:, per_page:, total_count: total_count || record_count
    )
  end

  describe "#initialize" do
    it "stores the pagination object" do
      pagination = build_pagination
      component = described_class.new(pagination)

      assert_same(pagination, component.pagination)
    end

    it "applies default options" do
      component = described_class.new(build_pagination)

      assert(component.options[:show_first])
      assert_not(component.options[:show_last])
      assert(component.options[:show_goto])
    end

    it "merges custom options with defaults" do
      component = described_class.new(build_pagination, show_first: false, show_last: true)

      assert_not(component.options[:show_first])
      assert(component.options[:show_last])
      assert(component.options[:show_goto])
    end
  end

  describe "show predicates" do
    it "returns show_first? from options" do
      assert(described_class.new(nil, show_first: true).show_first?)
      assert_not(described_class.new(nil, show_first: false).show_first?)
    end

    it "returns show_last? from options" do
      assert(described_class.new(nil, show_last: true).show_last?)
      assert_not(described_class.new(nil, show_last: false).show_last?)
    end

    it "returns show_goto? from options" do
      assert(described_class.new(nil, show_goto: true).show_goto?)
      assert_not(described_class.new(nil, show_goto: false).show_goto?)
    end

    it "returns show_page? from options" do
      assert(described_class.new(nil, show_page: true).show_page?)
      assert_not(described_class.new(nil, show_page: false).show_page?)
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
      assert(described_class.new(nil, show_page: true).show_badges?)
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
      assert_equal("Last", component.last_icon)
      assert_equal("Prev", component.prev_icon)
      assert_equal("Next", component.next_icon)
      assert_equal("Go", component.go_icon)
    end

    it "returns custom icon values" do
      component = described_class.new(nil,
        first_icon: "<<",
        last_icon: ">>",
        prev_icon: "<",
        next_icon: ">",
        go_icon: "Jump")

      assert_equal("<<", component.first_icon)
      assert_equal(">>", component.last_icon)
      assert_equal("<", component.prev_icon)
      assert_equal(">", component.next_icon)
      assert_equal("Jump", component.go_icon)
    end
  end

  describe "rendering prev/next navigation" do
    it "renders enabled prev and next links on a middle page" do
      render_inline(described_class.new(build_pagination(page: 2)))

      assert_selector(".pagination-prev-next a.page-link", text: "Prev")
      assert_selector(".pagination-prev-next a.page-link", text: "Next")
    end

    it "renders disabled prev when there is no previous page" do
      render_inline(described_class.new(build_pagination(page: 1)))

      assert_selector(".pagination-prev-next .page-item.disabled span.page-link", text: "Prev")
      assert_no_selector(".pagination-prev-next a.page-link", text: "Prev")
    end

    it "renders disabled next when there is no next page" do
      render_inline(described_class.new(build_pagination(page: 4)))

      assert_selector(".pagination-prev-next .page-item.disabled span.page-link", text: "Next")
      assert_no_selector(".pagination-prev-next a.page-link", text: "Next")
    end

    it "renders custom prev and next icons" do
      render_inline(described_class.new(build_pagination(page: 2), prev_icon: "<", next_icon: ">"))

      assert_selector(".pagination-prev-next a.page-link", text: "<")
      assert_selector(".pagination-prev-next a.page-link", text: ">")
    end

    it "renders all navigation as disabled when there are no records" do
      pagination = Pagination.new(
        Dummy.order(:id),
        build_request(url:),
        page: 1, per_page: 3, total_count: 0
      )
      render_inline(described_class.new(pagination))

      assert_selector(".page-item.disabled span.page-link", text: "First")
      assert_selector(".pagination-prev-next .page-item.disabled span.page-link", text: "Prev")
      assert_selector(".pagination-prev-next .page-item.disabled span.page-link", text: "Next")
    end
  end

  describe "rendering first button" do
    it "renders enabled first link when not on first page" do
      render_inline(described_class.new(build_pagination(page: 2)))

      assert_selector("a.page-link", text: "First")
    end

    it "renders disabled first button on first page" do
      render_inline(described_class.new(build_pagination(page: 1)))

      assert_selector(".page-item.disabled span.page-link", text: "First")
      assert_no_selector("a.page-link", text: "First")
    end

    it "hides the first button when show_first is false" do
      render_inline(described_class.new(build_pagination, show_first: false))

      assert_no_selector(".page-link", text: "First")
    end

    it "renders custom first icon" do
      render_inline(described_class.new(build_pagination(page: 2), first_icon: "<<"))

      assert_selector("a.page-link", text: "<<")
    end
  end

  describe "rendering last button" do
    it "renders enabled last link when not on last page" do
      render_inline(described_class.new(build_pagination(page: 2), show_last: true))

      assert_selector("a.page-link", text: "Last")
    end

    it "renders disabled last button on last page" do
      render_inline(described_class.new(build_pagination(page: 4), show_last: true))

      assert_selector(".page-item.disabled span.page-link", text: "Last")
      assert_no_selector("a.page-link", text: "Last")
    end

    it "hides the last button by default" do
      render_inline(described_class.new(build_pagination))

      assert_no_selector(".page-link", text: "Last")
    end

    it "renders custom last icon" do
      render_inline(described_class.new(build_pagination(page: 2), show_last: true, last_icon: ">>"))

      assert_selector("a.page-link", text: ">>")
    end
  end

  describe "rendering goto form" do
    it "renders the goto form by default" do
      render_inline(described_class.new(build_pagination))

      assert_selector("input[name='page']")
      assert_selector("button[type='submit']", text: "Go")
    end

    it "sets the input value to the current page" do
      render_inline(described_class.new(build_pagination(page: 3)))

      assert_selector("input[name='page'][value='3']")
    end

    it "hides the goto form when show_goto is false" do
      render_inline(described_class.new(build_pagination, show_goto: false))

      assert_no_selector("input[name='page']")
      assert_no_selector("button", text: "Go")
    end

    it "renders custom go icon" do
      render_inline(described_class.new(build_pagination, go_icon: "Jump"))

      assert_selector("button[type='submit']", text: "Jump")
    end
  end

  describe "rendering badges" do
    it "does not render badges by default" do
      render_inline(described_class.new(build_pagination))

      assert_no_selector(".badge")
    end

    it "renders page badge when show_page is enabled" do
      render_inline(described_class.new(build_pagination(page: 3), show_page: true))

      assert_selector(".badge", text: /page 3/)
    end

    it "renders total_pages badge when show_total_pages is enabled" do
      render_inline(described_class.new(build_pagination, show_total_pages: true))

      assert_selector(".badge", text: /total_pages 4/)
    end

    it "renders per_page badge when show_per_page is enabled" do
      render_inline(described_class.new(build_pagination(per_page: 5), show_per_page: true))

      assert_selector(".badge", text: /per_page 5/)
    end

    it "renders total_count badge when show_total_count is enabled" do
      render_inline(described_class.new(build_pagination(total_count: 250), show_total_count: true))

      assert_selector(".badge", text: /total_count 250/)
    end
  end
end
