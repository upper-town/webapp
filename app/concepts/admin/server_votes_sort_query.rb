module Admin
  class ServerVotesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "server_votes.id",
        "created_at" => "server_votes.created_at",
        "remote_ip" => "server_votes.remote_ip"
      }
    end
  end
end
