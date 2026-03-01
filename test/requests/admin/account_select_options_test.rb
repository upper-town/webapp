require "test_helper"

class Admin::AccountSelectOptionsRequestTest < ActionDispatch::IntegrationTest
  FRAME_ID = "admin_fetchable_multi_select_filter_options_account_ids"

  describe "GET /admin/account_select_options" do
    it "returns not_found when not authenticated" do
      get(admin_account_select_options_path)

      assert_response(:not_found)
    end

    it "returns HTML wrapped in matching turbo-frame when Turbo-Frame header present" do
      sign_in_as_admin
      account = create_account
      account.user.update!(email: "alice@upper.town")

      get(
        admin_account_select_options_path,
        params: { ids: account.id },
        headers: { "Turbo-Frame" => FRAME_ID }
      )

      assert_response(:success)
      assert_equal("text/html", response.media_type)
      assert_includes(response.body, "<turbo-frame")
      assert_includes(response.body, "id=\"#{FRAME_ID}\"")
      assert_includes(response.body, "data-id=\"#{account.id}\"")
      assert_includes(response.body, "data-name=\"alice@upper.town\"")
      assert_includes(response.body, "alice@upper.town")
    end

    it "filters by search term when q param provided" do
      sign_in_as_admin
      account = create_account
      account.user.update!(email: "unique@upper.town")

      get(
        admin_account_select_options_path,
        params: { q: "unique" },
        headers: { "Turbo-Frame" => FRAME_ID }
      )

      assert_response(:success)
      assert_includes(response.body, "unique@upper.town")
      assert_includes(response.body, I18n.t("admin.shared.anonymous"))
    end

    it "returns selected options when no search term (for dropdown reopen after form submit)" do
      sign_in_as_admin
      account = create_account
      account.user.update!(email: "alice@upper.town")
      server = create_server
      create_server_vote(server:, game: server.game, account:)

      get(
        admin_account_select_options_path,
        params: {
          selected_ids: [account.id],
          only_with_votes: "true"
        },
        headers: { "Turbo-Frame" => FRAME_ID }
      )

      assert_response(:success)
      assert_includes(response.body, "alice@upper.town")
      assert_includes(response.body, I18n.t("admin.shared.anonymous"))
    end

    it "always includes selected options in response even when they do not match search" do
      sign_in_as_admin
      matching = create_account
      matching.user.update!(email: "alice@upper.town")
      non_matching = create_account
      non_matching.user.update!(email: "bob@upper.town")
      server = create_server
      create_server_vote(server:, game: server.game, account: matching)
      create_server_vote(server:, game: server.game, account: non_matching)

      get(
        admin_account_select_options_path,
        params: {
          q: "alice",
          selected_ids: [non_matching.id],
          only_with_votes: "true"
        },
        headers: { "Turbo-Frame" => FRAME_ID }
      )

      assert_response(:success)
      assert_includes(response.body, "alice@upper.town", "search match should appear")
      assert_includes(response.body, "bob@upper.town", "selected option should appear even when it does not match search")
    end

    it "respects only_with_votes when true" do
      sign_in_as_admin
      account_with_vote = create_account
      account_with_vote.user.update!(email: "voter@upper.town")
      server = create_server
      create_server_vote(server:, game: server.game, account: account_with_vote)
      account_without_vote = create_account
      account_without_vote.user.update!(email: "novote@upper.town")

      get(
        admin_account_select_options_path,
        params: {
          ids: [account_with_vote.id, account_without_vote.id].join(","),
          only_with_votes: "true"
        },
        headers: { "Turbo-Frame" => FRAME_ID }
      )

      assert_response(:success)
      assert_includes(response.body, "voter@upper.town")
      assert_not_includes(response.body, "novote@upper.town")
    end

    it "returns HTML when Accept is text/html without Turbo-Frame" do
      sign_in_as_admin
      account = create_account
      account.user.update!(email: "alice@upper.town")

      get(admin_account_select_options_path, params: { ids: account.id })

      assert_response(:success)
      assert_equal("text/html", response.media_type)
      assert_includes(response.body, "alice@upper.town")
    end

  end
end
