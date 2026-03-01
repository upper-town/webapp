module HasCodes
  CODE_EXPIRATION = 30.minutes

  extend ActiveSupport::Concern

  class_methods do
    def code_generator
      CodeGenerator
    end

    def find_by_code(purpose, code_value)
      return if purpose.blank? || code_value.blank?

      joins(:codes)
        .where(codes: { purpose:, code_digest: code_generator.digest(code_value) })
        .where("codes.expires_at > ?", Time.current)
        .first
    end
  end

  def generate_code!(purpose, expires_in = nil, data = {})
    expires_in ||= CODE_EXPIRATION

    code_value, code_digest = self.class.code_generator.generate

    codes.create!(
      purpose:,
      expires_at: expires_in.from_now,
      data:,
      code_digest:
    )

    code_value
  end

  def expire_code!(purpose)
    return if purpose.blank?

    codes.where(purpose:).update_all(expires_at: 2.days.ago)
  end
end
