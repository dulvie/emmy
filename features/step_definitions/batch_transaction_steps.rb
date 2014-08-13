batch_name = 'Test batch'
warehouse_name = 'Test warehouse'
product_quantity = 20

Given /^a batch and warehouse exists$/ do
  FactoryGirl.create :batch, name: batch_name
  FactoryGirl.create :warehouse, name: warehouse_name
end

Given /^I fill in data for a manual transaction$/ do
  assert_equal true, page.has_content?('New manual')
  select batch_name, from: 'batch_transaction_batch_id'
  select warehouse_name, from: 'product_transaction_warehouse_id'
  fill_in 'batch_transaction_quantity', with: batch_quantity
end

Then /^warehouse should have test products$/ do
  p = Batch.find_by_name batch_name
  w = Warehouse.find_by_name warehouse_name
  shelf = w.shelves.where(batch: p).first
  assert_equal batch_quantity, shelf.quantity
end
