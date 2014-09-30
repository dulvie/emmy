
Given /^a batch with name "(.*?)" exists$/ do |batch_name|
  p = Batch.find_by_name batch_name
  unless p
    FactoryGirl.create :batch, name: batch_name
  end
end

Given /^a warehouse with name "(.*?)" exists$/ do |warehouse_name|
  w = Warehouse.find_by_name warehouse_name
  unless w
    FactoryGirl.create :warehouse, name: warehouse_name
  end
end

Given /^I select "(.*?)" as "(.*?)" warehouse$/ do |warehouse_name, side|
  select warehouse_name, from: "transfer_#{side}_warehouse_id"
end

Given /^I fill in "(.*?)" as transfer_quantity$/ do |quantity|
  fill_in 'transfer_quantity', with: quantity
end

Given /^I fill in "(.*?)" as transfer_comments_attributes_0_body$/ do |text|
  fill_in 'transfer_comments_attributes_0_body', with: text
end

Given /^warehouse "(.*?)" has a shelf with (\d+) of batch named "(.*?)"$/ do |wh_name, quantity, batch_name|
  wh = Warehouse.find_by_name wh_name
  p = Batch.find_by_name batch_name
  m = Manual.new
  m.build_batch_transaction
  m.user = User.first
  m.warehouse = wh
  m.batch = p
  m.batch_transaction.quantity = quantity
  m.save!
  Resque.run!
end

Given /^the "(.*?)" warehouse have "(.*?)" of batch "(.*?)"$/ do |warehouse_name, quantity, batch_name|
  quantity = quantity.to_i
  wh = Warehouse.find_by_name warehouse_name
  p = Batch.find_by_name batch_name
  shelves = wh.shelves.where(batch_id: p.id)
  unless shelves.size > 0
    batch_transactions = wh.batch_transactions.where(batch_id: p.id)
    if batch_transactions.size > 0 && batch_transactions.sum(:quantity).eql?(quantity)
    else
      puts "Creating new manual transaction #{wh.id} #{p.id} #{quantity}"
      t = BatchTransaction.new warehouse_id: wh.id, batch_id: p.id, quantity: quantity
      c = {body: 'text'}
      m = Manual.new
      m.batch_transaction = t
      m.user = User.all.first
      m.comments.build(c)
      m.save
      Resque.run!
    end
  end
  shelf = shelves.first
  assert_equal quantity, shelf.quantity
  assert_equal quantity, wh.batch_transactions.where(batch_id: p.id).sum(:quantity)
end

Given /^a transfer of (\d+) "(.*?)" batch from "(.*?)" to "(.*?)" is created$/ do |quantity, batch_name, from_warehouse, to_warehouse|
  p = Batch.find_by_name batch_name
  from_wh = Warehouse.find_by_name from_warehouse
  to_wh = Warehouse.find_by_name to_warehouse
  t = Transfer.new
  t.from_warehouse = from_wh
  t.to_warehouse = to_wh
  t.batch = p
  t.quantity = quantity
  t.save
end

Given /^a transfer of (\d+) "(.*?)" batch is created and sent from "(.*?)" to "(.*?)"$/ do |quantity, batch_name, from_warehouse, to_warehouse|
  p = Batch.find_by_name batch_name
  from_wh = Warehouse.find_by_name from_warehouse
  to_wh = Warehouse.find_by_name to_warehouse
  t = Transfer.new
  t.from_warehouse = from_wh
  t.to_warehouse = to_wh
  t.batch = p
  t.quantity = quantity
  t.save
  t.send_package
  Resque.run!
  assert t.from_transaction
end

Then /^"(.*?)" warehouse should have (\d+) "(.*?)" batches on the shelves$/ do |warehouse_name, quantity, batch_name|
  quantity = quantity.to_i
  wh = Warehouse.find_by_name warehouse_name
  p = Batch.find_by_name batch_name
  assert_equal quantity, wh.shelves.where(batch_id: p.id).sum(:quantity).to_i
end

Given /^I click send$/ do
  page.driver.post("/transfers/1/send_package?locale=en", state_change_at: "#{Time.now}")
end
Given /^I click receive$/ do
  page.driver.post("/transfers/1/receive_package?locale=en", state_change_at: "#{Time.now}")
end