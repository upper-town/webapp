# frozen_string_literal: true

require "test_helper"

class ServerBannerImageTest < ActiveSupport::TestCase
  let(:described_class) { ServerBannerImage }

  describe "inheritance" do
    it "inherits from ImageUploadedFile" do
      assert_equal(ImageUploadedFile, described_class.superclass)
    end
  end

  describe "validations" do
    it "accepts valid PNG upload" do
      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      instance.validate

      assert(instance.valid?)
      assert_not(instance.errors.key?(:byte_size))
      assert_not(instance.errors.key?(:content_type))
    end

    it "accepts valid JPEG upload" do
      instance = described_class.new(uploaded_file: StringIO.new(jpeg_1px))
      instance.validate

      assert(instance.valid?)
      assert_not(instance.errors.key?(:byte_size))
      assert_not(instance.errors.key?(:content_type))
    end

    it "validates byte_size" do
      instance = described_class.new(uploaded_file: StringIO.new("a" * 512 * (1024 + 1)))
      instance.validate

      assert(instance.invalid?)
      assert(instance.errors.of_kind?(:byte_size, :invalid))
    end

    it "validates content_type" do
      instance = described_class.new(uploaded_file: StringIO.new("aaa"))
      instance.validate

      assert(instance.invalid?)
      assert(instance.errors.of_kind?(:content_type, :invalid))
    end

    it "accepts nil uploaded_file" do
      instance = described_class.new(uploaded_file: nil)
      instance.validate

      assert(instance.valid?)
    end
  end

  describe "inherited behavior" do
    it "delegates present?, blank?, presence to uploaded_file" do
      instance = described_class.new(uploaded_file: nil)
      assert(instance.blank?)
      assert_not(instance.present?)
      assert_nil(instance.presence)

      instance = described_class.new(uploaded_file: StringIO.new(png_1px))
      assert_not(instance.blank?)
      assert(instance.present?)
    end

    it "returns blob, byte_size, content_type, checksum from uploaded file" do
      instance = described_class.new(uploaded_file: StringIO.new(png_1px))

      assert_equal(png_1px, instance.blob)
      assert(instance.byte_size.positive?)
      assert_equal("image/png", instance.content_type)
      assert_equal(Digest::SHA256.hexdigest(png_1px), instance.checksum)
    end
  end

  let(:png_1px) do
    "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
    "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
    "\x0F\x00\x04\x85\x01\x80\x84\xA9\x8C!\x00\x00\x00\x00IEND\xAEB`\x82"
  end

  let(:jpeg_1px) do
    "\xFF\xD8\xFF\xDB\x00C\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" \
    "\xFF\xFF\xFF\xC0\x00\v\b\x00\x01\x00\x01\x01\x01\x11\x00\xFF\xC4\x00" \
    "\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x03\xFF\xC4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\xFF\xDA\x00\b\x01\x01\x00\x00?\x007\xFF\xD9"
  end
end
