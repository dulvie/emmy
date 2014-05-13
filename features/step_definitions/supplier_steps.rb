Given /^I click edit link for "(.*?)" supplier$/ do |supplier_name|
  assert true, page.has_content?(supplier_name)
  wh = Supplier.find_by_name "test supplier"
  assert_equal wh.name, supplier_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_supplier_path(wh)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" supplier$/ do |supplier_name|
  assert true, page.has_content?(supplier_name)
  wh = Supplier.find_by_name supplier_name
  delete_link = find(:xpath, "//a[contains(@href,'#{supplier_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

def supplier_valid_form_data
  fill_in "supplier_name", with: "test supplier"
end

def supplier_invalid_form_data
  fill_in "supplier_name", with: ""
end
