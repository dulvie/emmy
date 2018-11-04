batch_name = 'Test batch'
warehouse_name = 'Test warehouse'
batch_quantity = 20

Given /^a batch and warehouse exists$/ do
  FactoryBot.create :batch, name: batch_name
  FactoryBot.create :warehouse, name: warehouse_name
end

Given /^I fill in data for a manual transaction$/ do
  assert_equal true, page.has_content?('New Manual')
  select batch_name, from: 'manual_batch_id'
  select warehouse_name, from: 'manual_warehouse_id'
  fill_in 'manual_quantity', with: batch_quantity
  fill_in 'manual_comments_attributes_0_body', with: 'text'
end

Then /^warehouse should have test products$/ do
  p = Batch.find_by_name batch_name
  w = Warehouse.find_by_name warehouse_name
  shelf = w.shelves.where(batch: p).first
  assert_equal batch_quantity, shelf.quantity
end
