require "test_helper"

class Servers::VerifyAccounts::DownloadAndParseJsonFileTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyAccounts::DownloadAndParseJsonFile }

  describe "#call" do
    describe "when JSON is valid" do
      it "returns success with parsed_body" do
        server = create_server(site_url: "https://game-server.company.com/")
        body = { "accounts" => ["6e781bfd-353a-4e42-9077-6e5ac6cc477c"] }.to_json
        stub_request(:get, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body:)

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.success?)
        assert_equal(["6e781bfd-353a-4e42-9077-6e5ac6cc477c"], result.parsed_body["accounts"])
      end
    end

    describe "when JSON is invalid" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:get, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: "invalid json")

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.failure?)
      end
    end

    describe "when request fails" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        stub_request(:get, "https://game-server.company.com/uppertown_28c62f1f.json")
          .to_return(status: 500)

        result = described_class.call(server, "uppertown_28c62f1f.json")

        assert(result.failure?)
        assert(result.errors[:base].any? { |m| m.include?("Request failed") })
      end
    end
  end
end
