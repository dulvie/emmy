#require 'minitest/unit'
#World(MiniTest::Assertions)

Given /^I am on the home page$/  do
  visit "/"
end

Then /^I should see "(.*?)"$/ do |string|
  assert_equal true, page.has_content?(string)
end


Given /^I am a signed in user$/ do
  u = FactoryGirl.create(:user)
  #u.roles << FactoryGirl.create(:role)
  visit new_user_session_path
  fill_in "user_email", with: "testuser@example.com"
  fill_in "user_password", with: "abc123"
  click_on "Sign in"
end

Given /^I visit (.*?)_path$/ do |resource_name|
  visit send("#{resource_name}_path")
end

Given /^I click "(.*?)"$/ do |button_string|
  click_on button_string
end

Given(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  assert page.has_field?(field_name)
  fill_in field_name, with: field_value
end

Given(/^I fill in valid "(.*?)" data$/) do |resource_name|
  send("#{resource_name}_valid_form_data")
end

Then(/^I should see a "(.*?)" link$/) do |string|
  assert_equal page.has_link?(string), true
end
 
Given(/^a "(.*?)" with "(.*?)" equals to "(.*?)" exists$/) do |resource_name, field_name, field_value|
  m = resource_name.capitalize.constantize
  obj = m.send("find_by_#{field_name}", field_value)
  if obj
    assert_equals field_value, obj.send(field_name)
  else
    FactoryGirl.create resource_name.to_sym, field_name.to_sym => field_value
  end
end

Given(/^I click delete link for "(.*?)" warehouse$/) do |warehouse_name|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name warehouse_name
  delete_link = find(:xpath, "//a[contains(@href,'#{warehouse_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

Given(/^I confirm the alertbox$/) do
  # page.driver.browser.switch_to.alert.accept
  page.driver.accept_js_confirms!
end

Given(/^I click edit link for "(.*?)" warehouse$/) do |warehouse_name|
  assert true, page.has_content?(warehouse_name)
  wh = Warehouse.find_by_name "test warehouse"
  assert_equal wh.name, warehouse_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_warehouse_path(wh)}')]")
  edit_link.click
end

def warehouse_valid_form_data
  fill_in "warehouse_name", with: "test warehouse"
end
