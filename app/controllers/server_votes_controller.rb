class ServerVotesController < ApplicationController
  RATE_LIMIT_DURATION = -> { Rails.env.development? ? 1.minute : 6.hours }

  before_action :set_server, only: [:new, :create]

  rate_limit(
    to: 1,
    within: RATE_LIMIT_DURATION.call,
    by: -> { "#{request.remote_ip}:#{@server.game_id}" },
    with: -> do
      new
      flash.now[:alert] = t("shared.messages.too_many_votes_for_game", time: RATE_LIMIT_DURATION.call.inspect)
      render(:new, status: :too_many_requests)
    end,
    name: "create",
    only: [:create]
  )

  def show
    @server_vote = server_vote_from_params
  end

  def new
    @form = Servers::VoteForm.new(vote_form_params)
  end

  def create
    @form = Servers::VoteForm.new(vote_form_params)

    result = check_captcha

    if result.failure?
      flash.now[:alert] = result.errors
      render(:new, status: :unprocessable_entity)

      return
    end

    result = Servers::CreateVote.call(
      @form,
      server_id: @server.id,
      remote_ip: request.remote_ip,
      account_id: current_account&.id
    )

    if result.success?
      redirect_to(
        server_vote_path(result.server_vote),
        success: t("server_votes.create.success")
      )
    else
      flash.now[:alert] = result.errors
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def set_server
    @server = server_from_params
  end

  def server_from_params
    Server.find(params[:server_id])
  end

  def server_vote_from_params
    ServerVote.find(params[:id])
  end

  def vote_form_params
    attrs = if params.key?(:server_vote) || params.key?("server_vote")
      filtered = params.expect(server_vote: [:reference])
      (filtered[:server_vote] || filtered["server_vote"] || {}).to_h.symbolize_keys
    else
      {}
    end
    attrs[:reference] = params[:reference].presence || attrs[:reference]
    attrs
  end
end
