# frozen_string_literal: true

require "test_helper"

class Servers::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Create }

  let(:png_1px) do
    "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b" \
    "\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\rIDATx\xDAc\xFC\xCF\xC0P" \
    "\x0F\x00\x04\x85\x01\x80\x84\xA9\x8C!\x00\x00\x00\x00IEND\xAEB`\x82"
  end

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
    describe "when server is invalid" do
      it "returns failure with server errors and does not create server" do
        account = create_account
        form = Servers::CreateForm.new(server_attributes(name: ""))

        result = nil
        assert_no_difference(-> { Server.count }) do
          assert_no_difference(-> { ServerAccount.count }) do
            result = described_class.call(form, account:)
          end
        end

        assert(result.failure?)
        assert_nil(result.server)
        assert(result.errors.key?(:name))
      end
    end

    describe "when server_banner_image is invalid" do
      it "returns failure with server_banner_image errors and does not create server" do
        account = create_account
        form = Servers::CreateForm.new(server_attributes.merge(banner_image: StringIO.new("invalid")))

        result = nil
        assert_no_difference(-> { Server.count }) do
          assert_no_difference(-> { ServerAccount.count }) do
            result = described_class.call(form, account:)
          end
        end

        assert(result.failure?)
        assert_nil(result.server)
        assert(result.errors.key?(:banner_image))
      end
    end

    describe "when everything is valid without banner image" do
      it "creates server, associates account, and returns success" do
        account = create_account
        form = Servers::CreateForm.new(server_attributes)

        result = nil
        assert_difference(-> { Server.count }, 1) do
          assert_difference(-> { ServerAccount.count }, 1) do
            result = described_class.call(form, account:)
          end
        end

        assert(result.success?)
        assert_equal(Server.last, result.server)
        assert_includes(result.server.accounts, account)
        assert_not(result.server.banner_image.attached?)
      end
    end

    describe "when everything is valid with banner image" do
      it "creates server, attaches banner image, unapproves banner, associates account, and returns success" do
        account = create_account
        uploaded_file = StringIO.new(png_1px)
        form = Servers::CreateForm.new(server_attributes.merge(banner_image: uploaded_file))

        result = nil
        assert_difference(-> { Server.count }, 1) do
          assert_difference(-> { ServerAccount.count }, 1) do
            result = described_class.call(form, account:)
          end
        end

        assert(result.success?)
        assert_equal(Server.last, result.server)
        assert_includes(result.server.accounts, account)
        assert(result.server.banner_image.attached?)
        assert_nil(result.server.banner_image_approved_at)
      end
    end

    describe "when an error is raised during save" do
      it "raises error and does not create server" do
        account = create_account
        form = Servers::CreateForm.new(server_attributes)

        Server.stub_any_instance(:save!, -> { raise ActiveRecord::ActiveRecordError }) do
          assert_no_difference(-> { Server.count }) do
            assert_no_difference(-> { ServerAccount.count }) do
              assert_raises(ActiveRecord::ActiveRecordError) do
                described_class.call(form, account:)
              end
            end
          end
        end
      end
    end
  end
end
