module Servers
  class Create
    include Callable

    class Result < ApplicationResult
      attribute :server
    end

    attr_reader :account, :form

    def initialize(form, account:)
      @form = form
      @account = account
    end

    def call
      server = Server.new(form.server_attributes)
      server.move_errors(:game, :game_id) if server.invalid?

      if server.errors.any?
        return Result.failure(server.errors)
      end

      banner_form = build_banner_form
      if banner_form&.invalid?
        banner_errors = ActiveModel::Errors.new(server)
        banner_form.copy_errors_to(banner_errors)
        return Result.failure(banner_errors)
      end

      ApplicationRecord.transaction do
        server.save!

        if banner_form.present?
          io = banner_form.uploaded_file
          io.rewind if io.respond_to?(:rewind)
          server.banner_image.attach(
            io:,
            filename: banner_form.filename
          )
          server.unapprove_banner_image!
        end

        server.accounts << account
      end

      Result.success(server:)
    end

    private

    def build_banner_form
      return if form.banner_image.blank?

      ServerBannerImage.new(uploaded_file: form.banner_image)
    end
  end
end
