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



def warehouse_valid_form_data
  fill_in "warehouse_name", with: "test warehouse"
end
