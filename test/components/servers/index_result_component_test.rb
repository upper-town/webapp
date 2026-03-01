require "test_helper"

class Servers::IndexResultComponentTest < ViewComponent::TestCase
  let(:described_class) { Servers::IndexResultComponent }

  def build_component(server: create_server, server_stats_hash: {}, period: Periods::MONTH, show_more_info: true)
    described_class.new(server:, server_stats_hash:, period:, show_more_info:)
  end

  def build_stats_hash(year: {}, month: {}, week: {})
    {
      Periods::YEAR => { ranking_number: nil, vote_count: nil }.merge(year),
      Periods::MONTH => { ranking_number: nil, vote_count: nil }.merge(month),
      Periods::WEEK => { ranking_number: nil, vote_count: nil }.merge(week)
    }
  end

  describe "#format_ranking_number" do
    it "formats ranking numbers" do
      component = build_component

      [
        [nil,       "#--"],
        [-1,        "#--"],
        [0,         "#0"],
        [1_234,     "#1,234"],
        [99_999,    "#99,999"],
        [100_123,   "#100.1k"],
        [234_567,   "#234.6k"],
        [1_234_567,     "#1.235M"],
        [1_234_567_890, "#1.235B"]
      ].each do |value, expected|
        assert_equal(expected, component.format_ranking_number(value), "Failed for #{value.inspect}")
      end
    end
  end

  describe "#format_vote_count" do
    it "formats vote counts" do
      component = build_component

      [
        [nil,       "--"],
        [-1,        "--"],
        [0,         "0"],
        [42,        "42"],
        [99_999,    "99,999"],
        [100_123,   "100.1k"],
        [234_567,   "234.6k"],
        [1_234_567,     "1.235M"],
        [1_234_567_890, "1.235B"]
      ].each do |value, expected|
        assert_equal(expected, component.format_vote_count(value), "Failed for #{value.inspect}")
      end
    end
  end

  describe "rendering" do
    it "does not render when server is nil" do
      render_inline(build_component(server: nil))

      assert_no_selector("div")
    end

    it "renders the server name" do
      server = create_server(name: "My Test Server")

      render_inline(build_component(server:))

      assert_text("My Test Server")
    end

    it "renders the game name" do
      game = create_game(name: "Minecraft")
      server = create_server(game:)

      render_inline(build_component(server:))

      assert_text("Minecraft")
    end

    it "renders the country code" do
      server = create_server(country_code: "BR")

      render_inline(build_component(server:))

      assert_text("BR")
    end

    it "renders the server description when present" do
      server = create_server(description: "A great server")

      render_inline(build_component(server:))

      assert_text("A great server")
    end

    it "renders ranking numbers for all periods" do
      server = create_server
      stats = build_stats_hash(
        year:  { ranking_number: 1  },
        month: { ranking_number: 5  },
        week:  { ranking_number: 10 }
      )

      render_inline(build_component(server:, server_stats_hash: stats))

      assert_text("#1")
      assert_text("#5")
      assert_text("#10")
    end

    it "renders vote counts for all periods" do
      server = create_server
      stats = build_stats_hash(
        year:  { vote_count: 1_000 },
        month: { vote_count: 200   },
        week:  { vote_count: 50    }
      )

      render_inline(build_component(server:, server_stats_hash: stats))

      assert_text("1,000")
      assert_text("200")
      assert_text("50")
    end

    it "highlights the active period in world ranking" do
      server = create_server
      stats = build_stats_hash

      render_inline(build_component(server:, server_stats_hash: stats, period: Periods::WEEK))

      assert_selector(".border-primary", minimum: 1)
    end

    it "renders vote up and more info links" do
      server = create_server

      render_inline(build_component(server:))

      assert_link("Vote Up", href: new_server_vote_path(server))
      assert_link("More Info", href: server_path(server))
    end

    it "hides more info link when show_more_info is false" do
      server = create_server

      render_inline(build_component(server:, show_more_info: false))

      assert_link("Vote Up", href: new_server_vote_path(server))
      assert_no_link("More Info")
    end
  end
end
