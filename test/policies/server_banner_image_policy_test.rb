# frozen_string_literal: true

require "test_helper"

class ServerBannerImagePolicyTest < ActiveSupport::TestCase
  let(:described_class) { ServerBannerImagePolicy }

  let(:png_1px) do
    "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
    "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
    "\x8F\x00\x00\x01\x01\x00\x05\x1D\xF8\xA8\x00\x00\x00\x00IEND\xAEB`\x82".b
  end

  describe "#allowed?" do
    # current_admin_user is stubbed because it relies on Auth::ManageAdminSession
    # reading cookies from the request; the session/cookie plumbing is tested in
    # integration tests, so here we isolate the policy logic.
    describe "when current user is an admin" do
      it "returns true when banner_image is present regardless if it is approved" do
        server = create_server(banner_image_approved_at: nil)
        request = ActionDispatch::TestRequest.create
        server.banner_image.attach(io: StringIO.new(png_1px), filename: "test.png")
        admin_user = create_admin_user
        policy = described_class.new(server, request)

        policy.stub(:current_admin_user, admin_user) do
          assert(policy.allowed?)
        end
      end

      it "returns false when banner_image is not present" do
        server = create_server
        request = ActionDispatch::TestRequest.create
        admin_user = create_admin_user
        policy = described_class.new(server, request)

        policy.stub(:current_admin_user, admin_user) do
          assert_not(policy.allowed?)
        end
      end
    end

    describe "when current user is not an admin" do
      it "returns true when banner_image is present and approved" do
        server = create_server(banner_image_approved_at: Time.current)
        request = ActionDispatch::TestRequest.create
        server.banner_image.attach(io: StringIO.new(png_1px), filename: "test.png")
        policy = described_class.new(server, request)

        assert(policy.allowed?)
      end

      it "returns false when banner_image is present but not approved" do
        server = create_server(banner_image_approved_at: nil)
        request = ActionDispatch::TestRequest.create
        server.banner_image.attach(io: StringIO.new(png_1px), filename: "test.png")
        policy = described_class.new(server, request)

        assert_not(policy.allowed?)
      end

      it "returns false when banner_image is not present" do
        server = create_server
        request = ActionDispatch::TestRequest.create
        policy = described_class.new(server, request)

        assert_not(policy.allowed?)
      end
    end
  end
end
