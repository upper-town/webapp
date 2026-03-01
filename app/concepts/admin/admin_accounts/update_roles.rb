module Admin
  module AdminAccounts
    class UpdateRoles
      include Callable

      class Result < ApplicationResult
        attribute :admin_account
      end

      attr_reader :admin_account, :form

      def initialize(admin_account, form)
        @admin_account = admin_account
        @form = form
      end

      def call
        ids = form.role_ids
        admin_account.admin_account_roles.where.not(admin_role_id: ids).destroy_all

        existing_role_ids = admin_account.admin_account_roles.pluck(:admin_role_id)
        (ids - existing_role_ids).each do |rid|
          admin_account.admin_account_roles.create!(admin_role_id: rid)
        end

        admin_account.touch
        Result.success(admin_account:)
      end
    end
  end
end
