require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "root shows servers index" do
    visit(root_path)

    assert_text("No servers found")
  end
end
