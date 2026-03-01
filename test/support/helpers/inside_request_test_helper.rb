module InsideRequestTestHelper
  def sign_in_as_user(user = nil)
    user ||= create_user(email_confirmed_at: Time.current)
    token, token_digest, token_last_four = TokenGenerator::Session.generate

    user.sessions.create!(
      token_digest:,
      token_last_four:,
      remote_ip: "127.0.0.1",
      user_agent: "Test",
      expires_at: 1.month.from_now
    )

    cookies["session"] = { token: }.to_json

    user
  end

  def sign_in_via_session(user = nil)
    user ||= create_user(email_confirmed_at: Time.current)

    post(
      users_sessions_url,
      headers: request_headers,
      params: {
        users_session_form: {
          email: user.email,
          password: "testpass"
        }
      }
    )

    user
  end
end
