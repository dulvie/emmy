Given /^I click edit link for "(.*?)" customer in "(.*?)"$/ do |customer_name, o|
  assert true, page.has_content?(customer_name)
  c = Customer.find_by_name "test customer"
  assert_equal c.name, customer_name
  edit_link = first(:xpath, "//a[contains(@href,'#{customer_path(o, c)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" customer in "(.*?)"$/ do |customer_name, org_slug|
  assert true, page.has_content?(customer_name)
  o = Organization.find_by_slug(org_slug)
  assert o
  c = Customer.where('organization_id = ?',[o.id]).find_by_name customer_name
  assert_equal c.name, customer_name

  delete_link = find(".delete-icon.customer-#{c.id}")
  delete_link.click
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{customer_path(org_slug, c)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def customer_valid_form_data
  fill_in "customer_name", with: "test customer"
  select "30", from: 'customer_payment_term'
end

def customer_invalid_form_data
  fill_in "customer_name", with: ""
end
