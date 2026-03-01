# frozen_string_literal: true

require "test_helper"

class Admin::ServerStatusBadgesComponentTest < ViewComponent::TestCase
  let(:described_class) { Admin::ServerStatusBadgesComponent }

  describe "rendering" do
    it "renders not_verified badge when server has no status" do
      server = create_server(verified_at: nil, archived_at: nil, marked_for_deletion_at: nil)

      render_inline(described_class.new(server:))

      assert_selector("span.badge.text-bg-light", text: "Not verified")
    end

    it "renders verified badge when server is verified" do
      server = create_server(verified_at: nil, archived_at: nil, marked_for_deletion_at: nil)
      server.update!(verified_at: Time.current)

      render_inline(described_class.new(server:))

      assert_selector("span.badge.text-bg-success", text: "Verified")
    end

    it "renders multiple badges when server has multiple statuses" do
      server = create_server(verified_at: nil, archived_at: nil, marked_for_deletion_at: nil)
      server.update!(verified_at: Time.current, archived_at: Time.current)

      render_inline(described_class.new(server:))

      assert_selector("span.badge.text-bg-success", text: "Verified")
      assert_selector("span.badge.text-bg-secondary", text: "Archived")
    end
  end
end
