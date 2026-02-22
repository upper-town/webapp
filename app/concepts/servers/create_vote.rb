# frozen_string_literal: true

module Servers
  class CreateVote
    include Callable

    class Result < ApplicationResult
      attribute :server_vote
    end

    attr_reader :form, :server_id, :remote_ip, :account_id

    def initialize(form, server_id:, remote_ip:, account_id: nil)
      @form = form
      @server_id = server_id
      @remote_ip = remote_ip
      @account_id = account_id
    end

    def call
      server = find_server
      return server if server.is_a?(ApplicationResult)

      perform_create(server)
    end

    def find_server
      Server.find(server_id)
    rescue ActiveRecord::RecordNotFound
      Result.failure(:server, :not_found)
    end

    def perform_create(server)
      account = account_id.present? ? Account.find(account_id) : nil

      server_vote = ServerVote.new(
        server:,
        game: server.game,
        remote_ip:,
        account:,
        reference: form.reference
      )

      if server_vote.invalid?
        return Result.failure(server_vote.errors, server_vote:)
      end

      ActiveRecord::Base.transaction do
        server_vote.save!
        Webhooks::CreateEvents.call(server, WebhookEvent::SERVER_VOTE_CREATED, server_vote)
      end

      Result.success(server_vote:)
    end
  end
end
