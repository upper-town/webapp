# frozen_string_literal: true

module Servers
  class Update
    include Callable

    class Result < ApplicationResult
      attribute :server
    end

    attr_reader :server, :form

    def initialize(server, form)
      @server = server
      @form = form
    end

    def call
      server.assign_attributes(form.server_attributes)

      if server.invalid?
        server.move_errors(:game, :game_id)
        return Result.failure(server.errors)
      end

      server_banner_image = build_server_banner_image
      if server_banner_image.present? && server_banner_image.invalid?
        server_banner_image.copy_errors_to(server.errors)
        return Result.failure(server.errors)
      end

      ApplicationRecord.transaction do
        server.save!
        attach_banner_image(server, server_banner_image) if server_banner_image.present?
      end

      Result.success(server:)
    end

    private

    def build_server_banner_image
      return if form.banner_image.blank?

      ServerBannerImage.new(uploaded_file: form.banner_image)
    end

    def attach_banner_image(server, server_banner_image)
      io = server_banner_image.uploaded_file
      io.rewind if io.respond_to?(:rewind)
      server.banner_image.attach(
        io:,
        filename: server_banner_image.filename
      )
      server.unapprove_banner_image!
    end
  end
end
