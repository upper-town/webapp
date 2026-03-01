module AddFlashTypes
  extend ActiveSupport::Concern

  included do
    add_flash_types(
      :success,
      :primary,
      :secondary,
      :danger,
      :warning,
      :info,
      :light,
      :dark
    )
  end
end
