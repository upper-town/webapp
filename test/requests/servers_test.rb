# frozen_string_literal: true

require "test_helper"

class ServersRequestTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get servers_path(host: AppUtil.webapp_host, port: AppUtil.webapp_port)

    assert_response :success
  end

  test "GET index with valid game_id returns success" do
    game = create_game
    get servers_path(
      host: AppUtil.webapp_host,
      port: AppUtil.webapp_port,
      game_id: game.id
    )

    assert_response :success
  end

  test "GET index with invalid game_id returns not found" do
    get servers_path(
      host: AppUtil.webapp_host,
      port: AppUtil.webapp_port,
      game_id: 999_999
    )

    assert_response :not_found
  end

  test "GET show returns success for existing server" do
    server = create_server

    get server_path(
      server,
      host: AppUtil.webapp_host,
      port: AppUtil.webapp_port
    )

    assert_response :success
  end
end
