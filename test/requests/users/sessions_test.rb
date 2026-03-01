require "test_helper"

class Users::SessionsRequestTest < ActionDispatch::IntegrationTest
  it "responds with success" do
    get(users_sign_in_url)

    assert_response(:success)
  end

  it "redirects to dashboard when already signed in" do
    create_user(
      email: "signed_in@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )

    post(
      users_sessions_url,
      headers: request_headers,
      params: {
        users_session_form: {
          email: "signed_in@upper.town",
          password: "testpass"
        }
      }
    )
    assert_redirected_to(inside_dashboard_url)

    get(users_sign_in_url)

    assert_redirected_to(inside_dashboard_url)
  end

  it "signs in and redirects to dashboard with valid credentials" do
    user = create_user(
      email: "valid@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )

    assert_equal(0, user.sessions.count)

    post(
      users_sessions_url,
      headers: request_headers,
      params: {
        users_session_form: {
          email: "valid@upper.town",
          password: "testpass"
        }
      }
    )

    assert_redirected_to(inside_dashboard_url)
    assert_equal(1, user.sessions.reload.count)
  end

  it "responds with unprocessable_entity when credentials are invalid" do
    post(
      users_sessions_url,
      params: {
        users_session_form: {
          email: "nonexistent@upper.town",
          password: "wrong"
        }
      }
    )

    assert_response(:unprocessable_entity)
  end

  it "signs out and redirects to root when signed in" do
    user = create_user(
      email: "signout@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )

    post(
      users_sessions_url,
      headers: request_headers,
      params: {
        users_session_form: {
          email: "signout@upper.town",
          password: "testpass"
        }
      }
    )
    assert_redirected_to(inside_dashboard_url)
    assert_equal(1, user.sessions.reload.count)

    get(users_sign_out_url)

    assert_redirected_to(root_url)
    assert_equal(0, user.sessions.reload.count)
  end
end
