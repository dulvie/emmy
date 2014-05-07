FactoryGirl.define do
  factory :user do
    name "testuser"
    email "testuser@example.com"
    password "abc123"

    after :create do |user|
      user.roles << FactoryGirl.create(:role)
    end

  end

  factory :role do
    name :seller
  end

  factory :product do
    name "espresso"
    product_type Product::TYPES.first
    in_price 10000
    distributor_price 15000
    retail_price 20000
    vat 25
    weight 500
  end

  factory :warehouse do
    name "Coffee place"
    address "street 44"
    zip "08 001"
    city "Stockholm"
  end

  factory :customer do
    name "CoffeeHouse foobar"
  end

  factory :manual do
  end
end
