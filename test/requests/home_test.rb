# frozen_string_literal: true

require "test_helper"

class HomeRequestTest < ActionDispatch::IntegrationTest
  it "returns success for root" do
    get root_url(host: AppUtil.webapp_host, port: AppUtil.webapp_port)

    assert_response(:success)
  end

  it "returns success for up health check" do
    get "/up"

    assert_response(:success)
  end
end
