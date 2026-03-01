require "test_helper"

class Servers::VerifyAccounts::CheckJsonFileMetadataTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyAccounts::CheckJsonFileMetadata }

  describe "#call" do
    describe "when Content-Length exceeds max size" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:head, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 200, headers: { "Content-Length" => "513", "Content-Type" => "application/json" })

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.failure?)
        assert(result.errors[:base].any? { |m| m.include?("JSON file size must not be greater than 512 bytes") })
      end
    end

    describe "when Content-Type is not application/json" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:head, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 200, headers: { "Content-Length" => "100", "Content-Type" => "text/plain" })

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.failure?)
        assert(result.errors[:base].any? { |m| m.include?("Content-Type must be application/json") })
      end
    end

    describe "when metadata is valid" do
      it "returns success" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:head, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 200, headers: { "Content-Length" => "100", "Content-Type" => "application/json" })

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.success?)
      end
    end

    describe "when request fails" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:head, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 500)

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.failure?)
        assert(result.errors[:base].any? { |m| m.include?("Request failed") })
      end
    end
  end
end
