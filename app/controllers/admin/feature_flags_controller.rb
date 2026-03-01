module Admin
  class FeatureFlagsController < BaseController
    def index
      @search_term = params[:q]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::FeatureFlagsQuery.call(sort: @sort_column, sort_dir: @sort_direction)
      @pagination = Pagination.new(
        Admin::Queries::FeatureFlagsQuery.call(FeatureFlag, relation, @search_term),
        request,
        per_page: 50
      )
      @feature_flags = @pagination.results

      render(status: :ok)
    end

    def show
      @feature_flag = feature_flag_from_params
    end

    def new
      @form = Admin::FeatureFlags::Form.new
    end

    def create
      @form = Admin::FeatureFlags::Form.new(feature_flag_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:new, status: :unprocessable_entity)
        return
      end

      result = Admin::FeatureFlags::Create.call(@form)

      if result.success?
        flash[:notice] = t("admin.feature_flags.create.success")
        redirect_to(admin_feature_flag_path(result.feature_flag))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @feature_flag = feature_flag_from_params
      @form = Admin::FeatureFlags::Form.new(feature_flag: @feature_flag)
    end

    def update
      @feature_flag = feature_flag_from_params
      @form = Admin::FeatureFlags::Form.new(feature_flag: @feature_flag, **feature_flag_form_params)

      if @form.invalid?
        flash.now[:alert] = @form.errors
        render(:edit, status: :unprocessable_entity)
        return
      end

      result = Admin::FeatureFlags::Update.call(@feature_flag, @form)

      if result.success?
        flash[:notice] = t("admin.feature_flags.update.success")
        redirect_to(admin_feature_flag_path(result.feature_flag))
      else
        @form.errors.merge!(result.errors)
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def feature_flag_from_params
      FeatureFlag.find(params[:id])
    end

    def feature_flag_form_params
      filtered = params.expect(feature_flag: [:name, :value, :comment])
      (filtered[:feature_flag] || filtered["feature_flag"] || {}).to_h.symbolize_keys.compact
    end
  end
end
