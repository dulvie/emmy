Given /^I click edit link for "(.*?)" customer in "(.*?)"$/ do |customer_name, o|
  assert true, page.has_content?(customer_name)
  c = Customer.find_by_name "test customer"
  assert_equal c.name, customer_name
  edit_link = first(:xpath, "//a[contains(@href,'#{customer_path(o, c)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" customer in "(.*?)"$/ do |customer_name, o|
  assert true, page.has_content?(customer_name)
  c = Customer.find_by_name customer_name
  assert_equal c.name, customer_name
  delete_link = find(:xpath, "//a[@ng_click]")
  delete_link.click
  confirm_link = find(:xpath, "//a[contains(@href, '{{obj}}')]")
  confirm_link.click
  #page.find('href').find(:xpath, ".//a[contains(@href, '/customers/'+wh)]").each{|r| puts tr.text}
  #delete_link = first(:xpath, "//a[contains(@href, :text('#{customers_path}'))]")
  #delete_link.click
end

def customer_valid_form_data
  fill_in "customer_name", with: "test customer"
end

def customer_invalid_form_data
  fill_in "customer_name", with: ""
end
