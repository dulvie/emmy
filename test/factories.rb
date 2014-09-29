FactoryGirl.define do
  factory :organisation do
    name 'test organisation'

  end
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

  factory :unit do
    name 'kg'
  end

  factory :vat do
    name '12 procent'
    vat_percent 12
  end

  factory :item do
    name 'espresso'
    unit Unit.all.first || FactoryGirl.create(:unit)
    vat Vat.all.first || FactoryGirl.create(:vat)
    item_type 'sales'
    item_group 'refined'
  end

  factory :batch do
    name "espresso 2014"
    in_price 10000
    distributor_price 15000
    retail_price 20000
    item Item.all.first || FactoryGirl.create(:item)
  end

  factory :warehouse do
    name "Coffee place"
    address "street 44"
    zip "08 001"
    city "Stockholm"
  end

  factory :customer do
    name "CoffeeHouse foobar"
    payment_term 30
  end

  factory :supplier do
    name "Some farmer collective"
  end

  factory :manual do
  end
end
