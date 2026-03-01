module Admin
  module AdminRoles
    class UpdateForm < ApplicationModel
      attribute :permission_ids, default: -> { [] }

      def self.model_name
        ActiveModel::Name.new(AdminRole, nil, "AdminRole")
      end

      validate :validate_permission_ids_exist

      def permission_ids
        Array(super).map(&:to_i).reject(&:zero?).uniq
      end

      private

      def validate_permission_ids_exist
        return if permission_ids.empty?

        invalid = permission_ids - AdminPermission.pluck(:id)
        errors.add(:permission_ids, :invalid) if invalid.any?
      end
    end
  end
end
