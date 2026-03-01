module Admin
  class IndexActionsComponent < ApplicationComponent
    attr_reader :view_path, :edit_path, :extra_actions, :link_options

    # @param view_path [String] path for the View action
    # @param edit_path [String, nil] optional path for the Edit action
    # @param extra_actions [Array<Hash>] optional array of { path:, label:, **html_options }
    # @param link_options [Hash] optional html options merged into View and Edit links
    def initialize(view_path:, edit_path: nil, extra_actions: [], link_options: {})
      super()

      @view_path = view_path
      @edit_path = edit_path
      @extra_actions = extra_actions
      @link_options = link_options
    end

    def edit?
      edit_path.present?
    end
  end
end
