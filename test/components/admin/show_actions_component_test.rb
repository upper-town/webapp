require "test_helper"

class Admin::ShowActionsComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ShowActionsComponent }

  describe "rendering" do
    it "renders back link with back_path" do
      render_inline(described_class.new(back_path: admin_games_path))

      assert_selector("a.btn.btn-secondary[href='#{admin_games_path}']", text: "Back")
      assert_selector("[data-controller='back-link']")
    end

    it "renders back label from locale" do
      render_inline(described_class.new(back_path: admin_users_path))

      assert_selector("a", text: I18n.t("admin.shared.show_actions.back"))
    end

    it "renders action links when actions provided" do
      game = create_game
      render_inline(described_class.new(
                      back_path: admin_games_path,
                      actions: [
                        { path: edit_admin_game_path(game), label: I18n.t("admin.shared.edit") }
                      ]
                    ))

      assert_selector("a[href='#{edit_admin_game_path(game)}']", text: "Edit")
    end

    it "renders multiple action links" do
      user = create_user
      render_inline(described_class.new(
                      back_path: admin_users_path,
                      actions: [
                        { path: edit_admin_user_path(user), label: "Edit" },
                        { path: "/custom", label: "Custom Action" }
                      ]
                    ))

      assert_selector("a[href='#{edit_admin_user_path(user)}']", text: "Edit")
      assert_selector("a[href='/custom']", text: "Custom Action")
    end

    it "renders btn-group" do
      render_inline(described_class.new(back_path: admin_games_path))

      assert_selector(".btn-group")
    end
  end

  describe "#back_label" do
    it "returns translated back label" do
      component = described_class.new(back_path: "/")

      assert_equal(I18n.t("admin.shared.show_actions.back"), component.back_label)
    end
  end

  describe "attr_readers" do
    it "exposes back_path and actions" do
      component = described_class.new(back_path: "/back", actions: [{ path: "/edit", label: "Edit" }])

      assert_equal("/back", component.back_path)
      assert_equal([{ path: "/edit", label: "Edit" }], component.actions)
    end
  end
end
