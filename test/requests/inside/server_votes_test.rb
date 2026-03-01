require "test_helper"

module Inside
  class ServerVotesRequestTest < ActionDispatch::IntegrationTest
    describe "GET /i/server_votes" do
      it "redirects to sign in when not authenticated" do
        get(inside_server_votes_path)

        assert_redirected_to(users_sign_in_url)
      end

      it "returns success when authenticated" do
        user = create_user(email_confirmed_at: Time.current)
        create_account(user:)
        sign_in_as_user(user)

        get(inside_server_votes_path)

        assert_response(:success)
      end

      it "shows empty state when account has no votes" do
        user = create_user(email_confirmed_at: Time.current)
        create_account(user:)
        sign_in_as_user(user)

        get(inside_server_votes_path)

        assert_response(:success)
        assert_select "h5", text: "No votes yet"
      end

      it "shows votes when account has votes" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server(name: "My Favorite Server")
        create_server_vote(server:, account:)
        sign_in_as_user(user)

        get(inside_server_votes_path)

        assert_response(:success)
        assert_select "a", text: "My Favorite Server"
      end
    end
  end
end
