# frozen_string_literal: true

require "test_helper"

class Users::SessionsRequestTest < ActionDispatch::IntegrationTest
  def url_options
    { host: AppUtil.webapp_host, port: AppUtil.webapp_port }
  end

  test "GET sign_in renders sign-in form" do
    get users_sign_in_url(**url_options)

    assert_response :success
  end

  test "GET sign_in when already signed in redirects to dashboard" do
    user = create_user(
      email: "signed_in@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )
    user.create_account! unless user.account.present?

    post users_sessions_url(**url_options), params: {
      users_session: { email: "signed_in@upper.town", password: "testpass" }
    }, headers: request_headers
    assert_redirected_to inside_dashboard_url(**url_options)

    get users_sign_in_url(**url_options)

    assert_redirected_to inside_dashboard_url(**url_options)
  end

  test "POST create with valid credentials signs in and redirects to dashboard" do
    user = create_user(
      email: "valid@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )
    user.create_account! unless user.account.present?

    post users_sessions_url(**url_options), params: {
      users_session: { email: "valid@upper.town", password: "testpass" }
    }, headers: request_headers

    assert_redirected_to inside_dashboard_url(**url_options)
  end

  test "POST create with invalid credentials re-renders form" do
    post users_sessions_url(**url_options), params: {
      users_session: { email: "nonexistent@upper.town", password: "wrong" }
    }

    assert_response :unprocessable_entity
  end

  test "GET sign_out when signed in signs out and redirects to root" do
    user = create_user(
      email: "signout@upper.town",
      password: "testpass",
      email_confirmed_at: Time.current
    )
    user.create_account! unless user.account.present?

    post users_sessions_url(**url_options), params: {
      users_session: { email: "signout@upper.town", password: "testpass" }
    }, headers: request_headers
    assert_redirected_to inside_dashboard_url(**url_options)

    get users_sign_out_url(**url_options)

    assert_redirected_to root_url(**url_options)
  end
end
