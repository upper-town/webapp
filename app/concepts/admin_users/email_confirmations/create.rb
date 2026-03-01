module AdminUsers
  module EmailConfirmations
    class Create
      include Callable

      attr_reader :email

      def initialize(email)
        @email = email
      end

      def call
        AdminUsers::Create.call(email)
      end
    end
  end
end
