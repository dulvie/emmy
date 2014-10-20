Given /^I click edit link for "(.*?)" supplier in "(.*?)"$/ do |supplier_name, o|
  assert true, page.has_content?(supplier_name)
  s = Supplier.find_by_name "test supplier"
  assert_equal s.name, supplier_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_supplier_path(o, s)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" supplier in "(.*?)"$/ do |supplier_name, org_slug|
  assert true, page.has_content?(supplier_name)
  s = Supplier.find_by_name supplier_name
  delete_link = find(".delete-icon.supplier-#{s.id}")
  delete_link.click
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{supplier_path(org_slug, s)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def supplier_valid_form_data
  fill_in "supplier_name", with: "test supplier"
end

def supplier_invalid_form_data
  fill_in "supplier_name", with: ""
end
