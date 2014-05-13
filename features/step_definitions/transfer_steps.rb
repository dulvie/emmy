Given /^a product with name "(.*?)" exists$/ do |product_name|
  p = Product.find_by_name product_name
  unless p
    FactoryGirl.create :product, name: product_name
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

Given /^warehouse "(.*?)" has a shelf with (\d+) of product named "(.*?)"$/ do |wh_name, quantity, product_name|
  wh = Warehouse.find_by_name wh_name
  p = Product.find_by_name product_name
  m = Manual.new
  m.build_transaction
  m.user = User.first
  m.warehouse = wh
  m.product = p
  m.transaction.quantity = quantity
  m.save!
  Resque.run!
end

Given /^the "(.*?)" warehouse have "(.*?)" of product "(.*?)"$/ do |warehouse_name, quantity, product_name|
  quantity = quantity.to_i
  wh = Warehouse.find_by_name warehouse_name
  p = Product.find_by_name product_name
  shelves = wh.shelves.where(product_id: p.id)
  unless shelves.size > 0
    transactions = wh.transactions.where(product_id: p.id)
    if transactions.size > 0 && transactions.sum(:quantity).eql?(quantity)
    else
      puts "Creating new manual transaction"
      t = Transaction.new warehouse_id: wh.id, product_id: p.id, quantity: quantity
      t.parent = FactoryGirl.build :manual
      t.parent.user = User.all.first
      t.save
      Resque.run!
    end
  end
  shelf = shelves.first
  assert_equal quantity, shelf.quantity
  assert_equal quantity, wh.transactions.where(product_id: p.id).sum(:quantity)
end

Given /^a transfer of (\d+) "(.*?)" product from "(.*?)" to "(.*?)" is created$/ do |quantity, product_name, from_warehouse, to_warehouse|
  p = Product.find_by_name product_name
  from_wh = Warehouse.find_by_name from_warehouse
  to_wh = Warehouse.find_by_name to_warehouse
  t = Transfer.new
  t.from_warehouse = from_wh
  t.to_warehouse = to_wh
  t.product = p
  t.quantity = quantity
  t.save
end

Given /^a transfer of (\d+) "(.*?)" product is created and sent from "(.*?)" to "(.*?)"$/ do |quantity, product_name, from_warehouse, to_warehouse|
  p = Product.find_by_name product_name
  from_wh = Warehouse.find_by_name from_warehouse
  to_wh = Warehouse.find_by_name to_warehouse
  t = Transfer.new
  t.from_warehouse = from_wh
  t.to_warehouse = to_wh
  t.product = p
  t.quantity = quantity
  t.save
  t.send_package
  Resque.run!
  assert t.from_transaction
end

Then /^"(.*?)" warehouse should have (\d+) "(.*?)" products on the shelves$/ do |warehouse_name, quantity, product_name|
  quantity = quantity.to_i
  wh = Warehouse.find_by_name warehouse_name
  p = Product.find_by_name product_name
  assert_equal quantity, wh.shelves.where(product_id: p.id).sum(:quantity).to_i
end


=begin


# @todo Refactor needed, can better factories make this one cleaner?


Given /^a transfer is created for product "(.*?)" between "(.*?)" and "(.*?)" warehouses$/ do |product_name, from_wh, to_wh|
  product = Product.find_by_name product_name
  to_warehouse = Warehouse.find_by_name to_wh 
  from_warehouse = Warehouse.find_by_name from_wh
  tr = Transfer.new
  tr.product = product
  tr.from_warehouse = from_warehouse
  tr.to_warehouse = to_warehouse
  tr.quantity = 50
  assert tr.save
  #Resque.run!
  #puts Resque.info.inspect
  assert Transfer.where(product_id: product.id).where(to_warehouse_id: to_warehouse.id).count > 0
  assert Transfer.where(product_id: product.id).where(from_warehouse_id: from_warehouse.id).count > 0
end

Then /^"(.*?)" warehouse should have (\d+) products on the shelves$/ do |wh_name, quantity|
  quantity = quantity.to_i
  wh = Warehouse.find_by_name wh_name
  puts "warehouse #{wh_name} should have #{quantity} products on shelves:"
  puts wh.shelves.all.inspect
  assert_equal quantity, wh.shelves.sum(:quantity)
end

=end
