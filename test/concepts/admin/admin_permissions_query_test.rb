# frozen_string_literal: true

require "test_helper"

class Admin::AdminPermissionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminPermissionsQuery }

  describe "#call" do
    it "returns all admin permissions ordered by key" do
      perm_z = create_admin_permission(key: "zebra")
      perm_a = create_admin_permission(key: "alpha")

      assert_equal(
        [perm_a, perm_z],
        described_class.new.call
      )
    end
  end
end
