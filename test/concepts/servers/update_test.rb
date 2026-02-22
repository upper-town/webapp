# frozen_string_literal: true

require "test_helper"

class Servers::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Update }

  def server_attributes(overrides = {})
    game = create_game
    {
      game_id: game.id,
      country_code: overrides.fetch(:country_code, "US"),
      name: overrides.fetch(:name, "Server #{SecureRandom.base58}"),
      site_url: overrides.fetch(:site_url, "https://server-#{SecureRandom.base58}.upper.town/"),
      description: overrides[:description],
      info: overrides[:info]
    }.compact
  end

  describe "#call" do
    it "updates server with valid attributes" do
      server = create_server(name: "Old Name")
      form = Servers::CreateForm.new(
        server_attributes(name: "New Name", site_url: server.site_url)
      )

      result = described_class.call(server, form)

      assert(result.success?)
      assert_equal(server, result.server)
      server.reload
      assert_equal("New Name", server.name)
    end

    it "returns failure when form is invalid" do
      server = create_server
      original_name = server.name
      form = Servers::CreateForm.new(server_attributes(name: "", site_url: server.site_url))

      result = described_class.call(server, form)

      assert(result.failure?)
      assert(result.errors.key?(:name))
      assert_equal(original_name, server.reload.name)
    end

    it "attaches new banner image when provided" do
      png_1px = "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
        "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
        "\x0F\x00\x04\x85\x01\x80\x84\xA9\x8C!\x00\x00\x00\x00IEND\xAEB`\x82"
      server = create_server
      form = Servers::CreateForm.new(
        server_attributes(site_url: server.site_url).merge(banner_image: StringIO.new(png_1px))
      )

      result = described_class.call(server, form)

      assert(result.success?)
      assert(server.reload.banner_image.attached?)
    end
  end
end
