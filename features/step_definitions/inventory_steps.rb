Given /^I have set up a inventory for warehouse "(.*?)"$/ do |warehouse_name|
  w = FactoryBot.create(:warehouse)
  w.name = warehouse_name
  w.save
  i = FactoryBot.create(:inventory)
  i.warehouse_id=w.id
  i.save
  inventory = Inventory.find_by_warehouse_id w.id
  assert_equal i.id, inventory.id
end

Given /^I click edit link for inventory in warehouse "(.*?)" for "(.*?)"$/ do |warehouse_name, o|
  w = Warehouse.find_by_name warehouse_name
  i = Inventory.find_by_warehouse_id w.id
  assert_equal i.warehouse.name, warehouse_name
  edit_link = first(:xpath, "//a[contains(@href,'#{inventory_path(o, i)}')]")
  edit_link.click
end

def inventory_valid_form_data
  select "test warehouse", from: 'inventory_warehouse_id'
  find(:xpath, "//input[@id='inventory_inventory_date']").set "2014-10-01"
end

def inventory_invalid_form_data
  select "", from: 'inventory_warehouse_id'
  find(:xpath, "//input[@id='inventory_inventory_date']").set "2014-10-01"
end