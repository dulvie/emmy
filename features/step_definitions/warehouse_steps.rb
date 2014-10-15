Given /^I click edit link for "(.*?)" warehouse in "(.*?)"$/ do |warehouse_name, org_slug|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name "test warehouse"
  assert_equal wh.name, warehouse_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_warehouse_path(org_slug, wh)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" warehouse in "(.*?)"$/ do |warehouse_name, org_slug|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name warehouse_name
  delete_link = find(".delete-icon.warehouse-#{wh.id}")
  delete_link.click
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{warehouse_path(org_slug, wh)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def warehouse_valid_form_data
  fill_in "warehouse_name", with: "test warehouse"
end
