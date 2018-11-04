FactoryBot.define do
  factory :organization do
    name 'test organization'
    organization_type 'Aktiebolag'
  end

  factory :user do
    name "testuser"
    email "testuser@example.com"
    password "abc123"
  end

  factory :unit do
    name 'kg'
    organization_id 1
  end

  factory :vat do
    name '12 procent'
    vat_percent 12
    organization_id 1
  end

  factory :item do
    name 'espresso'
    unit { FactoryBot.create(:unit) }
    vat { FactoryBot.create(:vat) }
    stocked 'true'
    item_type 'sales'
    item_group 'refined'
    organization_id 1
  end

  factory :batch do
    name "espresso 2014"
    in_price 10000
    distributor_price 15000
    retail_price 20000
    item { FactoryBot.create(:item) }
    organization_id 1
  end

  factory :warehouse do
    name "Coffee place"
    address "street 44"
    zip "08 001"
    city "Stockholm"
    organization_id 1
  end

  factory :inventory do
    warehouse_id 1
    inventory_date '2014-10-01'
    organization_id 1
  end

  factory :inventory_setup do
     
  
  end

  factory :customer do
    name "CoffeeHouse foobar"
    payment_term 30
    organization_id 1
  end

  factory :supplier do
    name "Some farmer collective"
    organization_id 1
  end

  factory :comment do
    body "Initial text"
  end

  factory :manual do
    user_id 1
    organization_id 1
  end
end
