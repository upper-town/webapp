module Admin
  module AdminUsers
    class EditForm < ApplicationModel
      attr_accessor :admin_user

      attribute :locked,        :boolean, default: nil
      attribute :locked_reason, :string,  default: nil
      attribute :locked_comment, :string, default: nil

      validates :locked_reason, presence: true, length: { maximum: 255 }, if: :locked?

      def initialize(admin_user:, **attrs)
        super(**attrs)
        self.admin_user = admin_user
        self.locked = admin_user.locked? if locked.nil?
        self.locked_reason = admin_user.locked_reason if locked_reason.nil?
        self.locked_comment = admin_user.locked_comment if locked_comment.nil?
      end

      def locked?
        locked == true
      end
    end
  end
end
