require "test_helper"

class CodeTest < ActiveSupport::TestCase
  let(:described_class) { Code }

  describe "associations" do
    it "belongs to user" do
      code = create_code

      assert(code.user.present?)
    end
  end

  describe ".find_by_code" do
    it "returns nil when code is blank" do
      assert_nil(described_class.find_by_code(nil))
      assert_nil(described_class.find_by_code(""))
    end

    it "finds a non-expired code by its code value" do
      freeze_time do
        code_value, code_digest = CodeGenerator.generate
        code = create_code(code_digest:, expires_at: 1.second.from_now)

        assert_equal(code, described_class.find_by_code(code_value))
      end
    end

    it "does not find an expired code by default" do
      freeze_time do
        code_value, code_digest = CodeGenerator.generate
        create_code(code_digest:, expires_at: 1.second.ago)

        assert_nil(described_class.find_by_code(code_value))
      end
    end

    it "finds an expired code when include_expired is true" do
      freeze_time do
        code_value, code_digest = CodeGenerator.generate
        code = create_code(code_digest:, expires_at: 1.second.ago)

        assert_equal(code, described_class.find_by_code(code_value, include_expired: true))
      end
    end

    it "returns nil when no code matches the digest" do
      assert_nil(described_class.find_by_code("NONEXISTENT"))
    end
  end

  describe ".expired" do
    it "returns codes with expires_at in the past" do
      freeze_time do
        code = create_code(expires_at: 1.second.ago)
        create_code(expires_at: 1.second.from_now)

        assert_includes(described_class.expired, code)
        assert_equal(1, described_class.expired.count)
      end
    end

    it "includes codes with expires_at exactly now" do
      freeze_time do
        code = create_code(expires_at: Time.current)

        assert_includes(described_class.expired, code)
      end
    end
  end

  describe ".not_expired" do
    it "returns codes with expires_at in the future" do
      freeze_time do
        create_code(expires_at: 1.second.ago)
        code = create_code(expires_at: 1.second.from_now)

        assert_includes(described_class.not_expired, code)
        assert_equal(1, described_class.not_expired.count)
      end
    end

    it "does not include codes with expires_at exactly now" do
      freeze_time do
        code = create_code(expires_at: Time.current)

        assert_not_includes(described_class.not_expired, code)
      end
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is at or before now, false when after" do
      freeze_time do
        code = build_code(expires_at: 1.second.ago)
        assert(code.expired?)

        code = build_code(expires_at: Time.current)
        assert(code.expired?)

        code = build_code(expires_at: 1.second.from_now)
        assert_not(code.expired?)
      end
    end
  end

  describe "#expire!" do
    it "sets expires_at to 1 day ago" do
      freeze_time do
        code = create_code(expires_at: 1.hour.from_now)
        code.expire!

        assert_equal(1.day.ago, code.reload.expires_at)
      end
    end
  end
end
