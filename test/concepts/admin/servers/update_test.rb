# frozen_string_literal: true

require "test_helper"

class Admin::Servers::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Admin::Servers::Update }

  let(:png_1px) do
    "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
    "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
    "\x0F\x00\x04\x85\x01\x80\x84\xA9\x8C!\x00\x00\x00\x00IEND\xAEB`\x82"
  end

  describe "#call" do
    describe "when server is invalid" do
      it "returns failure with server errors and does not update server" do
        server = create_server
        original_name = server.name
        form = Admin::Servers::EditForm.new(
          game_id: server.game_id,
          country_code: server.country_code,
          name: "",
          site_url: server.site_url,
          banner_image_approved: false
        )

        result = described_class.call(server, form)

        assert(result.failure?)
        assert_nil(result.server)
        assert(result.errors.key?(:name))
        assert_equal(original_name, server.reload.name)
      end
    end

    describe "when server_banner_image is invalid" do
      it "returns failure with banner_image errors and does not update server" do
        server = create_server
        original_name = server.name
        form = Admin::Servers::EditForm.new(
          game_id: server.game_id,
          country_code: server.country_code,
          name: "New Name",
          site_url: server.site_url,
          banner_image: StringIO.new("invalid"),
          banner_image_approved: false
        )

        result = described_class.call(server, form)

        assert(result.failure?)
        assert_nil(result.server)
        assert(result.errors.key?(:banner_image))
        assert_equal(original_name, server.reload.name)
      end
    end

    describe "when everything is valid without banner image" do
      it "updates server and returns success" do
        server = create_server
        new_name = "Updated Server Name"
        form = Admin::Servers::EditForm.new(
          game_id: server.game_id,
          country_code: server.country_code,
          name: new_name,
          site_url: server.site_url,
          banner_image_approved: false
        )

        result = described_class.call(server, form)

        assert(result.success?)
        assert_equal(server, result.server)
        assert_equal(new_name, server.reload.name)
      end
    end

    describe "when everything is valid with banner image" do
      it "updates server, attaches banner image, unapproves banner, and returns success" do
        server = create_server
        form = Admin::Servers::EditForm.new(
          game_id: server.game_id,
          country_code: server.country_code,
          name: server.name,
          site_url: server.site_url,
          banner_image: StringIO.new(png_1px),
          banner_image_approved: false
        )

        result = described_class.call(server, form)

        assert(result.success?)
        assert_equal(server, result.server)
        assert(server.reload.banner_image.attached?)
        assert_nil(server.banner_image_approved_at)
      end
    end

    describe "when banner_image_approved is true" do
      it "approves banner image" do
        server = create_server
        server.banner_image.attach(
          io: StringIO.new(png_1px),
          filename: "banner.png"
        )
        server.unapprove_banner_image!
        form = Admin::Servers::EditForm.new(
          game_id: server.game_id,
          country_code: server.country_code,
          name: server.name,
          site_url: server.site_url,
          banner_image_approved: true
        )

        result = described_class.call(server, form)

        assert(result.success?)
        assert(server.reload.banner_image_approved?)
      end
    end
  end
end
