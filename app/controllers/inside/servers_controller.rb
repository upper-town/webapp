# frozen_string_literal: true

module Inside
  class ServersController < BaseController
    MAX_VERIFIED_SERVERS_PER_ACCOUNT = 10
    MAX_NOT_VERIFIED_SERVERS_PER_ACCOUNT = 2

    before_action(
      :max_verified_servers_per_account,
      :max_not_verified_servers_per_account,
      only: [:new, :create]
    )

    def index
      @servers = current_account.servers
    end

    def new
      @form = Servers::CreateForm.new
    end

    def create
      @form = Servers::CreateForm.new(server_form_params)

      if @form.invalid?
        render(:new, status: :unprocessable_entity)

        return
      end

      result = Servers::Create.call(@form, account: current_account)

      if result.success?
        redirect_to(inside_servers_path, success: "Your server has been added.")
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @server = server_from_params
      @form = Servers::CreateForm.new(server_edit_form_params_from_server(@server))
    end

    def update
      @server = server_from_params
      @form = Servers::CreateForm.new(server_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Servers::Update.call(@server, @form)

      if result.success?
        redirect_to(inside_servers_path, success: t("inside.servers.update.success"))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    def archive
      server = server_from_params
      result = Servers::Archive.new(server).call

      if result.success?
        flash[:success] = "Server has been archived. " \
          "Servers that are archived and without votes will be deleted soon automatically."
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def unarchive
      server = server_from_params
      result = Servers::Unarchive.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.unarchive.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def mark_for_deletion
      server = server_from_params
      result = Servers::MarkForDeletion.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.mark_for_deletion.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def unmark_for_deletion
      server = server_from_params
      result = Servers::UnmarkForDeletion.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.unmark_for_deletion.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    private

    def server_from_params
      current_account.servers.find(params[:id])
    end

    def server_form_params
      filtered = params.expect(server: [
        :game_id,
        :country_code,
        :name,
        :site_url,
        :description,
        :info,
        :banner_image
      ])
      (filtered[:server] || filtered["server"] || {}).to_h.symbolize_keys
    end

    def server_edit_form_params_from_server(server)
      {
        game_id: server.game_id,
        country_code: server.country_code,
        name: server.name,
        site_url: server.site_url,
        description: server.description,
        info: server.info
      }.compact
    end

    def max_verified_servers_per_account
      count = current_account.servers.verified.count

      if count >= MAX_VERIFIED_SERVERS_PER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: t("inside.servers.max_verified_servers_per_account")
        )
      end
    end

    def max_not_verified_servers_per_account
      count = current_account.servers.not_verified.count

      if count >= MAX_NOT_VERIFIED_SERVERS_PER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: t("inside.servers.max_not_verified_servers_per_account")
        )
      end
    end
  end
end
