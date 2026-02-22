# frozen_string_literal: true

module Admin
  module AdminAccounts
    class UpdateRolesForm < ApplicationModel
      attribute :role_ids, default: -> { [] }

      def self.model_name
        ActiveModel::Name.new(AdminAccount, nil, "AdminAccount")
      end

      validate :validate_role_ids_exist

      def role_ids
        Array(super).map(&:to_i).reject(&:zero?).uniq
      end

      private

      def validate_role_ids_exist
        return if role_ids.empty?

        invalid = role_ids - AdminRole.pluck(:id)
        errors.add(:role_ids, :invalid) if invalid.any?
      end
    end
  end
end
