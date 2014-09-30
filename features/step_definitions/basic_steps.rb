Given /^database is clean$/ do
  DatabaseCleaner.clean
end

Given /^I do not have a user session$/ do
  # Nothing...
end

Given /^I visit the dashboard$/ do
  visit "/dashboard"
end

Given /^I am on the home page$/  do
  visit "/"
end

Then /^I should see "(.*?)"$/ do |string|
  unless page.has_content?(string)
    puts page.body
  end
  assert_equal true, page.has_content?(string)
end

Given /^I am a signed in user$/ do
  u = FactoryGirl.create(:user)
  o = FactoryGirl.build(:organization)
  oc = Services::OrganizationCreator.new(o, u)
  assert oc.save
  u.default_organization_id = o.id
  u.save
  visit new_user_session_path
  fill_in "user_email", with: u.email
  fill_in "user_password", with: u.password
  click_button "Sign in"
end

Given /^I am a signed in user without an organization$/ do
  u = FactoryGirl.create(:user)
  visit new_user_session_path
  fill_in "user_email", with: u.email
  fill_in "user_password", with: u.password
  click_button "Sign in"
end

Given /^I visit (.*?)_path$/ do |resource_name|
  visit send("#{resource_name}_path")
end

Given /^I click "([^"]*?)"$/ do |button_string|
  puts "trying to click #{button_string}"
  click_on button_string, match: :first
end

Given(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  assert page.has_field?(field_name)
  fill_in field_name, with: field_value
end

Given /^I select "(.*?)" as "(.*?)"$/ do |option_text, field_name|
  select option_text, from: field_name
end

Given(/^I fill in valid "(.*?)" data$/) do |resource_name|
  send("#{resource_name}_valid_form_data")
end

Given /^I fill in invalid "(.*?)" data$/ do |resource_name|
  puts "will call #{resource_name}_invalid_form_data"
  send("#{resource_name}_invalid_form_data")
end

Given /^a couple of "(.*?)" exists$/ do |resources_name|
  puts "will call create_#{resources_name}"
  send("create_#{resources_name}")
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
    new_obj = FactoryGirl.create(resource_name.to_sym, field_name.to_sym => field_value)
    assert field_value.eql?(new_obj.send(field_name))
  end
end

Given(/^I confirm the alertbox$/) do
  # page.driver.browser.switch_to.alert.accept
  page.driver.accept_js_confirms!
end

Then /^Resque should perform work$/ do
  Resque.run!
end
Given /^I wait for resque to perform work$/ do
  Resque.run!
end

Given /^I see "(.*?)" in the page$/ do |string|
  unless page.has_content? string
    puts page.body
  end
  assert page.has_content? string
end

Then /^I should not see "(.*?)"$/ do |string|
  assert (! page.has_content?(string))
end


Given /^I click the first row$/ do
  page.execute_script(%Q{$('table tbody td:first-child a').click();})
end

Then(/^I should see a button with text "(.*?)"$/) do |string|
  if (page.has_button?(string) || page.has_selector?('a.btn', text: string))
    assert true
  else
    puts page.body
    assert false
  end
end

Then(/^I should not see a button with text "(.*?)"$/) do |string|
  #if  || page.has_link?(string, text: string))
  if (page.has_button?(string) || page.has_selector?('a.btn', text: string))
    puts page.body
    assert false
  else
    assert true
  end
end
