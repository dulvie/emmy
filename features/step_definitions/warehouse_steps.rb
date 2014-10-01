Given /^I click edit link for "(.*?)" warehouse in "(.*?)"$/ do |warehouse_name, org_name|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name "test warehouse"
  assert_equal wh.name, warehouse_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_warehouse_path(org_name, wh.id)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" warehouse$/ do |warehouse_name|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name warehouse_name
  delete_link = find(:xpath, "//a[contains(@href,'#{warehouse_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

def warehouse_valid_form_data
  fill_in "warehouse_name", with: "test warehouse"
end
