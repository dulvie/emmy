Given /^database posts exists to create a new sale$/ do
  c = FactoryGirl.create :customer

  p = FactoryGirl.create :product
  w = FactoryGirl.create :warehouse
  m = FactoryGirl.create :manual
  t = m.build_product_transaction quantity: 100
  m.product = p
  m.warehouse = w
  m.save
  Resque.run!
  w = Warehouse.all.first
  assert w.shelves.count > 0
end

def sale_valid_form_data
  select 'Coffee place', from: "sale_warehouse_id"
  select 'CoffeeHouse foobar', from: "sale_customer_id"
end
