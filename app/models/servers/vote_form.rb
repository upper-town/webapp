module Servers
  class VoteForm < ApplicationModel
    attribute :reference, :string, default: nil

    def self.model_name
      ActiveModel::Name.new(ServerVote, nil, "ServerVote")
    end
  end
end
