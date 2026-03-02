module Admin
  class AdminPermissionsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_permissions.id",
        "key" => "admin_permissions.key",
        "description" => "admin_permissions.description"
      }
    end
  end
end
