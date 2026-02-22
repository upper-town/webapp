# frozen_string_literal: true

require "test_helper"

class ServerBannerImageTest < ActiveSupport::TestCase
  let(:described_class) { ServerBannerImage }

  it "inherits from ImageUploadedFileForm" do
    assert_equal(ImageUploadedFileForm, described_class.superclass)
  end
end
