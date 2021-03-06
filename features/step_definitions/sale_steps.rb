Given /^database posts exists to create a new sale$/ do
  c = FactoryGirl.create :customer

  p = FactoryGirl.create :batch
  w = FactoryGirl.create :warehouse
  m = FactoryGirl.create :manual
  t = m.build_product_transaction quantity: 100
  m.batch = p
  m.warehouse = w
  m.save
  Resque.run!
  w = Warehouse.all.first
  assert w.shelves.count > 0
end

Given /^a fresh sale exists$/ do
  step "database posts exists to create a new sale"
  s = Sale.new warehouse_id: Warehouse.all.first.id, customer_id: Customer.all.first.id
  s.user_id = User.all.first.id
  assert s.save
end

Given /^I click the first sale$/  do
  sale = Sale.all.first
  click_on "##{sale.id}"
end

Given /^a sale in state item_complete with some one sale_item$/ do
  step "a fresh sale exists"
  s = Sale.all.first
  p = Product.all.first
  item = s.sale_items.build(product_id: p.id, quantity: 2, price: p.retail_price)
  assert item.save
  assert s.mark_item_complete
end


Given /^a sale in state start_processing$/ do
  step "a sale in state item_complete with some one sale_item"
  s = Sale.all.first
  assert s.start_processing
end

Given /^a sale in state start_processing and delivered$/ do
  step "a sale in state start_processing"
  s = Sale.all.first
  assert s.deliver_goods
end

Given /^a sale in state start_processing and paid$/ do
  step "a sale in state start_processing"
  s = Sale.all.first
  assert s.pay
end


# ------------------ new steps -------------------#
Given /^the warehouse "(.*?)" have a shelf with "(.*?)" of the batch "(.*?)"$/ do |warehouse, quantity, batch|
  quantity = quantity.to_i
  w = Warehouse.find_by_name warehouse
  o = w.organization
  i = FactoryGirl.build :item, name: batch.split(" ").first
  i.organization_id = o.id
  assert_save i

  b = i.batches.build(name: batch, quantity: quantity)
  assert_save b

  m = FactoryGirl.build :manual
  m.organization_id = o.id
  m.batch_transaction = BatchTransaction.new warehouse_id: w.id, batch_id: b.id, quantity: (quantity - 1)
  assert_save m

end

