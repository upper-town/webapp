module AdminRequestTestHelper
  def sign_in_as_admin(admin_user = nil)
    admin_user ||= create_admin_user(email_confirmed_at: Time.current)
    token, token_digest, token_last_four = TokenGenerator::AdminSession.generate

    admin_user.sessions.create!(
      token_digest:,
      token_last_four:,
      remote_ip: "127.0.0.1",
      user_agent: "Test",
      expires_at: 1.month.from_now
    )

    cookies["admin_session"] = { token: }.to_json

    admin_user
  end
end
