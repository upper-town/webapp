module Admin
  class AdminRolesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "admin_roles.id",
        "key" => "admin_roles.key",
        "description" => "admin_roles.description"
      }
    end
  end
end
