Given /^I click edit link for "(.*?)" customer$/ do |customer_name|
  assert true, page.has_content?(customer_name)
  wh = Customer.find_by_name "test customer"
  assert_equal wh.name, customer_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_customer_path(wh)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" customer$/ do |customer_name|
  assert true, page.has_content?(customer_name)
  wh = Customer.find_by_name customer_name
  delete_link = find(:xpath, "//a[contains(@href,'#{customer_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

def customer_valid_form_data
  fill_in "customer_name", with: "test customer"
end

def customer_invalid_form_data
  fill_in "customer_name", with: ""
end