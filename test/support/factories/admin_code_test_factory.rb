ApplicationRecordTestFactoryHelper.define(:admin_code, AdminCode,
  admin_user: -> { build_admin_user },
  purpose: -> { "email_confirmation" },
  expires_at: -> { 30.days.from_now },
  code_digest: -> { Digest::SHA256.hexdigest(SecureRandom.base58(8).upcase) }
)
