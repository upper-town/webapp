# frozen_string_literal: true

require "test_helper"

class HomeRequestTest < ActionDispatch::IntegrationTest
  test "root returns success" do
    get root_url(host: AppUtil.webapp_host, port: AppUtil.webapp_port)

    assert_response :success
  end

  test "up health check returns success" do
    get "/up"

    assert_response :success
  end
end
