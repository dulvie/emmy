
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

Given /^warehouse "(.*?)" has a shelf with (\d+) of batch named "(.*?)" on "(.*?)"$/ do |wh_name, quantity, batch_name, org_slug|
  o = Organization.find_by_slug org_slug
  wh = Warehouse.find_by_name wh_name
  p = Batch.find_by_name batch_name

  b = BatchTransaction.new(warehouse: wh, batch: p, quantity: quantity)
  b.organization_id = o.id
  m = Manual.new
  m.user = User.first
  m.organization_id = o.id
  c = m.comments.build(user_id: 1, body: "Initial seed manual product_transaction")
  c.organization_id = o.id
  m.batch_transaction = b
  assert m.save
  Resque.run!
  s = wh.shelves.where(batch_id: p.id).first
  assert_equal quantity.to_i, s.quantity.to_i
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
      t = BatchTransaction.new warehouse_id: wh.id, batch_id: p.id, quantity: quantity, organization_id: 1
      c = {body: 'text'}
      m = Manual.new
      m.batch_transaction = t
      m.user = User.all.first
      m.organization_id = 1
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
  t.organization_id = 1
  assert t.save
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

Given /^I click send for organization "(.*?)"$/ do |org_slug|
  url = "/"+ org_slug + "/transfers/1/send_package?locale=en"
  page.driver.post(url, state_change_at: "#{Time.now}")
end
Given /^I click receive for organization "(.*?)"$/ do |org_slug|
  url = receive_package_transfer_path(org_slug, 1)
  page.driver.post(url, state_change_at: "#{Time.now}")
end
