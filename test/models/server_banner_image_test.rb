# frozen_string_literal: true

require "test_helper"

class ServerBannerImageTest < ActiveSupport::TestCase
  let(:described_class) { ServerBannerImage }

  it "inherits from ImageUploadedFile" do
    assert_equal(ImageUploadedFile, described_class.superclass)
  end
end
