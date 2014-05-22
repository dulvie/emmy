product_name = 'Test product'
warehouse_name = 'Test warehouse'
product_quantity = 20

Given /^a product and warehouse exists$/ do
  FactoryGirl.create :product, name: product_name
  FactoryGirl.create :warehouse, name: warehouse_name
end

Given /^I fill in data for a manual transaction$/ do
  assert_equal true, page.has_content?('New manual')
  select product_name, from: 'product_transaction_product_id'
  select warehouse_name, from: 'product_transaction_warehouse_id'
  fill_in 'product_transaction_quantity', with: product_quantity
end

Then /^warehouse should have test products$/ do
  p = Product.find_by_name product_name
  w = Warehouse.find_by_name warehouse_name
  shelf = w.shelves.where(product: p).first
  assert_equal product_quantity, shelf.quantity
end
