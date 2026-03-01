require "test_helper"

class Admin::IndexActionsComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::IndexActionsComponent }

  describe "rendering" do
    it "renders view link" do
      user = create_user
      render_inline(described_class.new(view_path: admin_user_path(user)))

      assert_selector("a.btn[href='#{admin_user_path(user)}']", text: I18n.t("admin.shared.view"))
    end

    it "renders edit link when edit_path provided" do
      user = create_user
      render_inline(described_class.new(
                      view_path: admin_user_path(user),
                      edit_path: edit_admin_user_path(user)
                    ))

      assert_selector("a[href='#{edit_admin_user_path(user)}']", text: I18n.t("admin.shared.edit"))
    end

    it "does not render edit link when edit_path is nil" do
      user = create_user
      render_inline(described_class.new(view_path: admin_user_path(user), edit_path: nil))

      assert_selector("a", text: I18n.t("admin.shared.view"))
      assert_no_selector("a", text: I18n.t("admin.shared.edit"))
    end

    it "renders extra actions" do
      user = create_user
      render_inline(described_class.new(
                      view_path: admin_user_path(user),
                      extra_actions: [
                        { path: "/custom", label: "Custom" }
                      ]
                    ))

      assert_selector("a[href='/custom']", text: "Custom")
    end

    it "renders multiple extra actions" do
      user = create_user
      render_inline(described_class.new(
                      view_path: admin_user_path(user),
                      extra_actions: [
                        { path: "/a", label: "Action A" },
                        { path: "/b", label: "Action B" }
                      ]
                    ))

      assert_selector("a[href='/a']", text: "Action A")
      assert_selector("a[href='/b']", text: "Action B")
    end

    it "applies link_options to view and edit links" do
      user = create_user
      render_inline(described_class.new(
                      view_path: admin_user_path(user),
                      edit_path: edit_admin_user_path(user),
                      link_options: { "data-turbo-frame" => "_top" }
                    ))

      assert_selector("a[data-turbo-frame='_top']", count: 2)
    end

    it "renders btn-group" do
      user = create_user
      render_inline(described_class.new(view_path: admin_user_path(user)))

      assert_selector(".btn-group.btn-group-sm")
    end
  end

  describe "#edit?" do
    it "returns true when edit_path is present" do
      component = described_class.new(view_path: "/view", edit_path: "/edit")

      assert(component.edit?)
    end

    it "returns false when edit_path is nil" do
      component = described_class.new(view_path: "/view", edit_path: nil)

      assert_not(component.edit?)
    end

    it "returns false when edit_path is empty string" do
      component = described_class.new(view_path: "/view", edit_path: "")

      assert_not(component.edit?)
    end
  end

  describe "attr_readers" do
    it "exposes view_path, edit_path, extra_actions, link_options" do
      component = described_class.new(
        view_path: "/view",
        edit_path: "/edit",
        extra_actions: [{ path: "/x", label: "X" }],
        link_options: { class: "custom" }
      )

      assert_equal("/view", component.view_path)
      assert_equal("/edit", component.edit_path)
      assert_equal([{ path: "/x", label: "X" }], component.extra_actions)
      assert_equal({ class: "custom" }, component.link_options)
    end
  end
end
