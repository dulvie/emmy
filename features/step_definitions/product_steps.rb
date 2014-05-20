Given /^I click edit link for "(.*?)" product$/ do |product_name|
  assert true, page.has_content?(product_name)
  wh = Product.find_by_name "test product"
  assert_equal wh.name, product_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_product_path(wh)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" product$/ do |product_name|
  assert true, page.has_content?(product_name)
  wh = Product.find_by_name product_name
  delete_link = find(:xpath, "//a[contains(@href,'#{product_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

def product_valid_form_data
  fill_in "product_name", with: "test product"
  fill_in "product_vat", with: "25"
  select 'refined', from: 'product_product_type'
end

def product_invalid_form_data
  fill_in "product_name", with: ""
end
