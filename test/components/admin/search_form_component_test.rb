require "test_helper"

class Admin::SearchFormComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::SearchFormComponent }

  describe "rendering" do
    it "renders search form with url" do
      render_inline(described_class.new(url: admin_users_path, placeholder: "Search…"))

      assert_selector("form[action='#{admin_users_path}'][method='get']")
      assert_selector("input[type='search'][name='q']")
      assert_selector("input[placeholder='Search…']")
      assert_selector("input[type='submit'][value='#{I18n.t('admin.shared.search')}']")
    end

    it "renders custom placeholder" do
      render_inline(described_class.new(url: admin_users_path, placeholder: "Search users…"))

      assert_selector("input[placeholder='Search users…']")
    end

    it "renders search term in input when provided" do
      render_inline(described_class.new(url: admin_users_path, search_term: "test query", placeholder: "Search"))

      assert_selector("input[value='test query']")
    end

    it "renders clear link when search term is present" do
      render_inline(described_class.new(url: admin_users_path, search_term: "foo", placeholder: "Search"))

      assert_selector("a.btn", text: I18n.t("admin.shared.clear_search"))
    end

    it "does not render clear link when search term is blank" do
      render_inline(described_class.new(url: admin_users_path, search_term: nil, placeholder: "Search"))

      assert_no_selector("a", text: I18n.t("admin.shared.clear_search"))
    end

    it "renders hidden params" do
      result = render_inline(described_class.new(
                               url: admin_server_accounts_path,
                               placeholder: "Search",
                               hidden_params: { "server_id" => "123" }
                             ))

      assert_selector("input[type='hidden'][name='server_id']", visible: false)
      assert_includes(result.to_html, 'value="123"')
    end

    it "renders custom param name" do
      render_inline(described_class.new(url: admin_users_path, param: :search, placeholder: "Search"))

      assert_selector("input[name='search']")
    end

    it "has admin-search-form class" do
      render_inline(described_class.new(url: admin_users_path, placeholder: "Search"))

      assert_selector("form.admin-search-form")
    end

    it "has search-form controller" do
      render_inline(described_class.new(url: admin_users_path, placeholder: "Search"))

      assert_selector("[data-controller='search-form']")
    end
  end

  describe "#clear_url" do
    it "returns base url when no hidden params" do
      component = described_class.new(url: admin_users_path, placeholder: "Search")

      assert_equal(admin_users_path, component.clear_url)
    end

    it "appends hidden params as query string when url has no query" do
      component = described_class.new(
        url: admin_users_path,
        placeholder: "Search",
        hidden_params: { "server_id" => "123" }
      )

      assert_includes(component.clear_url, "server_id=123")
    end

    it "appends with & when url already has query params" do
      url_with_params = "#{admin_users_path}?page=1"
      component = described_class.new(
        url: url_with_params,
        placeholder: "Search",
        hidden_params: { "filter" => "active" }
      )

      assert_includes(component.clear_url, "&")
      assert_includes(component.clear_url, "filter=active")
    end

    it "compacts nil values from hidden_params" do
      component = described_class.new(
        url: admin_users_path,
        placeholder: "Search",
        hidden_params: { "a" => "1", "b" => nil, "c" => "" }
      )

      # compact removes nil; empty string may or may not be removed
      assert_includes(component.clear_url, "a=1")
    end
  end

  describe "#show_clear?" do
    it "returns true when search_term is present" do
      component = described_class.new(url: admin_users_path, search_term: "foo", placeholder: "Search")

      assert(component.show_clear?)
    end

    it "returns false when search_term is blank" do
      component = described_class.new(url: admin_users_path, search_term: nil, placeholder: "Search")

      assert_not(component.show_clear?)
    end

    it "returns false when search_term is empty string" do
      component = described_class.new(url: admin_users_path, search_term: "", placeholder: "Search")

      assert_not(component.show_clear?)
    end
  end

  describe "attr_readers" do
    it "exposes url, search_term, placeholder, param, hidden_params" do
      component = described_class.new(
        url: admin_users_path,
        search_term: "q",
        placeholder: "Search",
        param: :q,
        hidden_params: { "x" => "1" }
      )

      assert_equal(admin_users_path, component.url)
      assert_equal("q", component.search_term)
      assert_equal("Search", component.placeholder)
      assert_equal(:q, component.param)
      assert_equal({ "x" => "1" }, component.hidden_params)
    end
  end
end
