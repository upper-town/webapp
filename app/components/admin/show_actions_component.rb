module Admin
  class ShowActionsComponent < ApplicationComponent
    attr_reader :back_path, :actions

    # @param back_path [String] fallback path when there is no browser history (e.g. index)
    # @param actions [Array<Hash>] optional array of { path:, label:, **html_options }
    def initialize(back_path:, actions: [])
      super()

      @back_path = back_path
      @actions = actions
    end

    def back_label
      I18n.t("admin.shared.show_actions.back")
    end
  end
end
