# frozen_string_literal: true

require "application_system_test_case"

class ServersIndexTest < ApplicationSystemTestCase
  describe "#index" do
    it "shows No results when no servers" do
      visit(servers_path)

      assert_text("No results")
    end

    it "shows servers ranked by vote count" do
      freeze_time do
        game = create_game(name: "Test Game", slug: "test-game")
        server1 = create_server(game:, name: "Alpha Server", country_code: "US")
        server2 = create_server(game:, name: "Beta Server", country_code: "US")

        reference_date = Periods.reference_date_for(Periods::MONTH, Time.current)
        create_server_stat(
          server: server1,
          game:,
          period: Periods::MONTH,
          reference_date:,
          ranking_number: 1,
          vote_count: 100
        )
        create_server_stat(
          server: server2,
          game:,
          period: Periods::MONTH,
          reference_date:,
          ranking_number: 2,
          vote_count: 50
        )

        visit(servers_path)

        assert_text("Alpha Server")
        assert_text("Beta Server")
        assert_text("Test Game")

        # Higher-ranked server (Alpha) appears before lower-ranked (Beta)
        body = page.body
        assert(
          body.index("Alpha Server") < body.index("Beta Server"),
          "Alpha Server should appear before Beta Server in ranking"
        )
      end
    end
  end
end
