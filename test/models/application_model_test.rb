# frozen_string_literal: true

require "test_helper"

class ApplicationModelTest < ActiveSupport::TestCase
  let(:described_class) { ApplicationModel }

  it "accepts attributes with type and default" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end

    instance = model_class.new
    assert_equal("", instance.name)
    assert_nil(instance.age)
    assert_equal(0.00, instance.amount)

    instance.name = "John"
    instance.age = "42"
    instance.amount = "10.99"
    assert_equal("John", instance.name)
    assert_equal(42, instance.age)
    assert_equal(10.99, instance.amount)

    instance = model_class.new(name: "John", age: "42", amount: "10.99")
    assert_equal("John", instance.name)
    assert_equal(42, instance.age)
    assert_equal(10.99, instance.amount)
    assert_equal(
      {
        "name" => "John",
        "age" => 42,
        "amount" => 10.99
      },
      instance.attributes
    )
  end

  it "serializes to JSON" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: "John", age: "42", amount: "10.99")

    assert_equal(
      '{"name":"John","age":42,"amount":10.99}',
      instance.to_json
    )
  end

  it "has access to NumberHelper methods" do
    model_class = Class.new(described_class) do
      attribute :amount, :float, default: 0.00

      def formatted_amount
        number_to_currency(amount)
      end
    end
    instance = model_class.new(amount: "10.99")

    assert_equal("$10.99", instance.formatted_amount)
  end

  it "has access to application routes methods" do
    model_class = Class.new(described_class) do
      def some_url
        root_url
      end
    end
    instance = model_class.new

    assert_equal(
      "http://#{AppUtil.webapp_host}:#{AppUtil.webapp_port}/",
      instance.some_url
    )
  end

  it "equals by attributes" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: "John", age: "42", amount: "10.99")

    other_instance = model_class.new(name: "John", age: 42, amount: 10.99)
    assert(instance == other_instance)

    other_instance.name = "Jane"
    assert_not(instance == other_instance)
  end

  it "equals by id" do
    model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end
    instance = model_class.new(id: 111, name: "John")

    other_instance = model_class.new(id: 111, name: "Jane")
    assert(instance == other_instance)

    other_instance.id = 222
    assert_not(instance == other_instance)
  end

  it "must be of the same class to be equal" do
    model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end
    other_model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end

    instance = model_class.new(id: 111, name: "John")
    other_instance = other_model_class.new(id: 111, name: "John")

    assert_not(instance == other_instance)
  end

  it "equals self (identity)" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
    end
    instance = model_class.new(name: "John")
    same = instance

    assert(instance == same)
  end

  it "does not equal nil" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
    end
    instance = model_class.new(name: "John")

    assert_not(instance.nil?)
  end

  it "does not equal object of different class" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
    end
    instance = model_class.new(name: "John")

    assert_not(instance == "John")
    assert_not(instance == { name: "John" })
  end

  it "does not equal by id when one has nil id" do
    model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end
    with_id = model_class.new(id: 111, name: "John")
    without_id = model_class.new(id: nil, name: "John")

    assert_not(with_id == without_id)
    assert_not(without_id == with_id)
  end

  it "supports validations via ActiveModel::Model" do
    model_class = Class.new(described_class) do
      attribute :email, :string, default: ""
      validates :email, presence: true

      def self.model_name
        ActiveModel::Name.new(self, nil, "TestForm")
      end
    end

    valid = model_class.new(email: "user@example.com")
    assert_predicate(valid, :valid?)

    invalid = model_class.new(email: "")
    assert_not(invalid.valid?)
    assert_includes(invalid.errors[:email], "can't be blank")
  end

  it "supports as_json for serialization" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :count, :integer, default: 0
    end
    instance = model_class.new(name: "Test", count: 42)

    assert_equal(
      { "name" => "Test", "count" => 42 },
      instance.as_json
    )
  end
end
