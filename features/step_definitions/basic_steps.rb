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
    puts "can not find: #{string}"
  end
  assert_equal true, page.has_content?(string)
end

# This is a copy/paste of the above Then.
# This should only be used to debug stuff.
Given /^I see "(.*?)"$/ do |string|
  unless page.has_content?(string)
    puts page.body
    puts "can not find: #{string}"
  end
  assert_equal true, page.has_content?(string)
end


Given /^I am signed in as a superadmin$/ do
  u = FactoryGirl.create(:user)
  r = u.organization_roles.build(name: OrganizationRole::ROLE_SUPERADMIN)
  r.organization_id = 0
  r.save!
  visit new_user_session_path
  fill_in "user_email", with: u.email
  fill_in "user_password", with: u.password
  click_button "Sign in"
end

Given /^I am signed in as an admin on "(.*?)"$/ do |organization_name|
  u = FactoryGirl.create(:user)
  assert u, "no user found"
  o = Organization.find_by_name organization_name
  assert o, "no organization found"
  r = u.organization_roles.build(name: OrganizationRole::ROLE_ADMIN)
  r.organization_id = o.id
  r.save!
  visit new_user_session_path
  fill_in "user_email", with: u.email
  fill_in "user_password", with: u.password
  click_button "Sign in"
  click_on organization_name
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

Given /^I sign in as "(.*?)" with password "(.*?)"$/ do |email, password|
  visit new_user_session_path
  fill_in "user_email", with: email
  fill_in "user_password", with: password
  click_button "Sign in"
end

Then /^a user with the role "(.*?)" on "(.*?)" should exist$/ do |role_name, organization_name|
  o = Organization.find_by_name organization_name
  assert o
  roles = o.organization_roles.map{|role| role.name}
  assert roles.include?(role_name)
end

Given /^I visit (.*?)_path$/ do |resource_name|
  visit send("#{resource_name}_path")
end

Given /^I visit (.*?)_path for "(.*?)"$/ do |resource_name, organization_slug|
  visit send("#{resource_name}_path", organization_slug: organization_slug)
end

Given /^I click "([^"]*?)"$/ do |button_string|
  puts "trying to click #{button_string}"
  if page.has_content?(button_string) or page.has_selector?("input[type=submit][value='#{button_string}']")
    click_on button_string, match: :first
  else
    puts page.body
    assert page.has_content?(button_string) || page.has_selector?("input[type=submit][value='#{button_string}']")
  end

end

Given /^I fill in "(.*?)" with "(.*?)"$/ do |field_name, field_value|
  puts page.body unless page.has_field?(field_name)

  assert page.has_field?(field_name), "unable to find field"
  fill_in field_name, with: field_value
end

Given /^I select "(.*?)" as "(.*?)"$/ do |option_text, field_name|
  select option_text, from: field_name
end

Given /^I fill in valid "(.*?)" data$/ do |resource_name|
  send("#{resource_name}_valid_form_data")
end

Given /^I fill in invalid "(.*?)" data$/ do |resource_name|
  puts "will call #{resource_name}_invalid_form_data"
  send("#{resource_name}_invalid_form_data")
end

Given /^I check "(.*?)"$/ do |name|
  check name
end
Given /^I choose "(.*?)"$/ do |name|
  choose name
end

Given /^I uncheck "(.*?)"$/ do |name|
  uncheck name
end

Given /^I fill in typeahead field "(.*?)" with "(.*?)"$/ do |field_id, value|
  page.execute_script "$('input[typeahead]').unbind('blur')"
  fill_in field_id, with: value
end


Given /^a couple of "(.*?)" exists$/ do |resources_name|
  puts "will call create_#{resources_name}"
  send("create_#{resources_name}")
end

Then /^I should see a "(.*?)" link$/ do |string|
  assert_equal page.has_link?(string), true
end

Given /^a "(.*?)" with "(.*?)" equals to "(.*?)" exists$/ do |resource_name, field_name, field_value|
  m = resource_name.capitalize.constantize
  obj = m.send("find_by_#{field_name}", field_value)
  if obj
    assert_equal field_value, obj.send(field_name)
  else
    new_obj = FactoryGirl.create(resource_name.to_sym, field_name.to_sym => field_value)
    assert field_value.eql?(new_obj.send(field_name))
  end
end

Given /^a "(.*?)" with "(.*?)" equals to "(.*?)" exists on "(.*?)"$/ do |resource_name, field_name, field_value, org_slug|
  o = Organization.find_by_slug(org_slug)
  assert o
  m = resource_name.capitalize.constantize
  obj = m.send("find_by_#{field_name}", field_value)
  if obj
    assert_equal field_value, obj.send(field_name)
    assert_equal o.id, obj.organization_id, "object does not belong to #{org_slug}"
  else
    new_obj = FactoryGirl.create(resource_name.to_sym, field_name.to_sym => field_value, organization_id: o.id)
    assert field_value.eql?(new_obj.send(field_name))

    assert_equal o.id, new_obj.organization_id, "failed to compare #{o.id} with #{new_obj.organization_id}"
  end
end



Given /^a "(.*?)" with "(.*?)" "(.*?)" does not exists$/ do |resource_name, field_name, field_value|
  m = resource_name.capitalize.constantize
  obj = m.send("find_by_#{field_name}", field_value)
  assert !obj, "#{resource_name} with #{field_name} = #{field_value} was found"
end


Given /^I confirm the alertbox$/ do
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

Then /^I should see a button with text "(.*?)"$/ do |string|
  if (page.has_button?(string) || page.has_selector?('a.btn', text: string))
    assert true
  else
    puts page.body
    assert false
  end
end

Then /^I should not see a button with text "(.*?)"$/ do |string|
  if (page.has_button?(string) || page.has_selector?('a.btn', text: string))
    puts page.body
    assert false
  else
    assert true
  end
end

Then /^I click the state button "(.*?)" and confirm the state change$/ do |string|
  click_on string
  confirm_link = find('.modal-body .btn.btn-primary')
  confirm_link.click
end



def assert_save(obj)
  assert obj.save, "failed to save #{obj.class.name} #{obj.inspect} #{obj.errors.full_messages}"
end
