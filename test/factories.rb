FactoryGirl.define do
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
end
