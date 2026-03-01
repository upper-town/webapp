module Seeds
  class CreateAdminAccounts
    include Callable

    attr_reader :admin_user_ids

    def initialize(admin_user_ids)
      @admin_user_ids = admin_user_ids
    end

    def call
      AdminAccount.insert_all(super_admin_account_hashes)

      result = AdminAccount.insert_all(admin_account_hashes)
      assign_admin_role_to_regular_accounts
      result.rows.flatten # account_ids
    end

    private

    SUPER_ADMIN_USER_IDS = [101, 202].freeze

    def admin_account_hashes
      (admin_user_ids - SUPER_ADMIN_USER_IDS).map do |admin_user_id|
        { admin_user_id: }
      end
    end

    def super_admin_account_hashes
      [
        { id: 101, admin_user_id: 101 },
        { id: 202, admin_user_id: 202 }
      ]
    end

    def assign_admin_role_to_regular_accounts
      admin_role = AdminRole.find_by!(key: "admin")
      regular_account_ids = AdminAccount.where.not(id: SUPER_ADMIN_USER_IDS).pluck(:id)
      return if regular_account_ids.empty?

      now = Time.current
      AdminAccountRole.insert_all(
        regular_account_ids.map { |admin_account_id|
          { admin_account_id:, admin_role_id: admin_role.id, created_at: now, updated_at: now }
        }
      )
    end
  end
end
