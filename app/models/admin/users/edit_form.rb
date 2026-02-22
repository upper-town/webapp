# frozen_string_literal: true

module Admin
  module Users
    class EditForm < ApplicationModel
      attr_accessor :user

      attribute :locked,        :boolean, default: nil
      attribute :locked_reason,  :string,  default: nil
      attribute :locked_comment, :string, default: nil

      validates :locked_reason, presence: true, length: { maximum: 255 }, if: :locked?

      def initialize(user:, **attrs)
        super(**attrs)
        self.user = user
        self.locked = user.locked? if locked.nil?
        self.locked_reason = user.locked_reason if locked_reason.nil?
        self.locked_comment = user.locked_comment if locked_comment.nil?
      end

      def locked?
        locked == true
      end
    end
  end
end
