require "test_helper"

class Inside::ServerCardComponentTest < ViewComponent::TestCase
  let(:described_class) { Inside::ServerCardComponent }

  def build_component(server: create_server, server_stats_hash: {}, period: Periods::MONTH)
    described_class.new(server:, server_stats_hash:, period:)
  end

  def build_stats_hash(year: {}, month: {})
    {
      Periods::YEAR => { ranking_number: nil, vote_count: nil }.merge(year),
      Periods::MONTH => { ranking_number: nil, vote_count: nil }.merge(month)
    }
  end

  describe "#render?" do
    it "returns false when server is nil" do
      component = build_component(server: nil)

      assert_not component.render?
    end

    it "returns true when server is present" do
      component = build_component

      assert component.render?
    end
  end

  describe "#format_ranking_number" do
    it "formats ranking numbers with # prefix" do
      component = build_component

      assert_equal("#--", component.format_ranking_number(nil))
      assert_equal("#--", component.format_ranking_number(-1))
      assert_equal("#0", component.format_ranking_number(0))
      assert_equal("#1,234", component.format_ranking_number(1_234))
      assert_equal("#100.1k", component.format_ranking_number(100_123))
    end
  end

  describe "#format_vote_count" do
    it "formats vote counts" do
      component = build_component

      assert_equal("--", component.format_vote_count(nil))
      assert_equal("--", component.format_vote_count(-1))
      assert_equal("0", component.format_vote_count(0))
      assert_equal("42", component.format_vote_count(42))
      assert_equal("100.1k", component.format_vote_count(100_123))
    end
  end

  describe "#stats" do
    it "returns stats for the server from server_stats_hash" do
      server = create_server
      stats_for_server = build_stats_hash(month: { ranking_number: 5, vote_count: 100 })
      server_stats_hash = { server.id => stats_for_server }
      component = build_component(server:, server_stats_hash:)

      assert_equal(5, component.stats.dig(Periods::MONTH, :ranking_number))
      assert_equal(100, component.stats.dig(Periods::MONTH, :vote_count))
    end

    it "returns empty hash when server has no stats" do
      server = create_server
      component = build_component(server:, server_stats_hash: {})

      assert_equal({}, component.stats)
    end
  end

  describe "rendering" do
    it "renders the server name and game" do
      game = create_game(name: "Minecraft")
      server = create_server(name: "My Server", game:)

      render_inline(build_component(server:))

      assert_text("My Server")
      assert_text("Minecraft")
    end

    it "renders edit, webhooks, and view page links" do
      server = create_server

      render_inline(build_component(server:))

      assert_link(I18n.t("inside.servers.index.edit"), href: edit_inside_server_path(server))
      assert_link(I18n.t("inside.servers.index.webhooks"), href: inside_server_webhook_configs_path(server))
      assert_link(I18n.t("inside.servers.index.view_page"), href: server_path(server))
    end

    it "renders ranking and vote count when server is not archived" do
      server = create_server
      stats_for_server = build_stats_hash(month: { ranking_number: 3, vote_count: 50 })
      server_stats_hash = { server.id => stats_for_server }

      render_inline(build_component(server:, server_stats_hash:))

      assert_text("#3")
      assert_text("50")
    end
  end
end
