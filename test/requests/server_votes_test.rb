# frozen_string_literal: true

require "test_helper"

class ServerVotesRequestTest < ActionDispatch::IntegrationTest
  def url_options
    { host: AppUtil.webapp_host, port: AppUtil.webapp_port }
  end

  test "GET show returns success for existing vote" do
    server_vote = create_server_vote

    get server_vote_path(
      server_vote,
      **url_options
    )

    assert_response :success
  end

  test "GET new returns success" do
    server = create_server

    get new_server_vote_path(
      server,
      **url_options
    )

    assert_response :success
  end
end
