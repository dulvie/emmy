def user_valid_form_data
  fill_in "user_email", with: "test@example.com"
  fill_in "user_password", with: "abc123"
  fill_in "user_password_confirmation", with: "abc123"
end

Given /^a user with the email "(.*?)" exists and have the role "(.*?)" on "(.*?)"$/ do |email, role_name, org_name|
  o = Organization.find_by_name org_name
  assert o
  u = FactoryBot.build(:user, email: email, name: email.gsub('@', ' '))
  r = u.organization_roles.build(name: role_name)
  r.organization_id = o.id
  r.save
  assert u.save
end

# Treat password differently, it needs to be checked with #valid_password?.
Then /^a user with email "(.*?)" should have password "(.*?)"$/ do |email, password|
  user = User.find_by_email email
  assert user, "no user found"
  assert user.valid_password?(password), "wrong password"
end

Then /^a user with email "(.*?)" should have "(.*?)" set to "(.*?)"$/ do |email, field, value|
  user = User.find_by_email email
  assert_equal user.send(field), value
end

Given /^a user with email "(.*?)" has "(.*?)" set to "(.*?)"$/ do |email, field, value|
  user = User.find_by_email email
  unless user.send(field) == value
    user.send("#{field}=", value)
    assert user.save
  end
  assert_equal user.send(field), value
end

Given /^a user with email "(.*?)" exists and have no roles on "(.*?)"$/ do |email, organization_name|
  o = Organization.find_by_name organization_name
  assert o, "no organization found"
  u = FactoryBot.create(:user, email: email, name: email.gsub('@', ''))
  assert u, "no user present"
  assert (u.organization_roles.where(organization_id: o.id).count == 0), "user already has a role"
end

Then /^a user with email "(.*?)" should have the "(.*?)" role on "(.*?)"$/ do |email, role_name, org_name|
  o = Organization.find_by_name org_name
  assert o, "no organization found"
  u = User.find_by_email email
  assert u, "no user found"
  u.organization_roles.each do |role|
    puts "#{u.name} has role #{role.name} on #{role.organization.name}"
  end
  assert (u.organization_roles.where(name: role_name).where(organization_id: o.id).count > 0), "no role found"
end

Then /^a user with email "(.*?)" should not have the "(.*?)" role on "(.*?)"$/ do |email, role_name, org_name|
  o = Organization.find_by_name org_name
  assert o, "no organization found"
  u = User.find_by_email email
  assert u, "no user found"
  assert (u.organization_roles.where(name: role_name).where(organization_id: o.id).count == 0), "role found"
end

Given /^a user with email "(.*?)" and password "(.*?)" exists$/ do |email, password|
  u = FactoryBot.create(:user, email: email, password: password, password_confirmation: password)
  assert u
  o = FactoryBot.build(:organization)
  assert o
  oc = Services::OrganizationCreator.new(o, u)
  assert oc.save
  u.default_organization_id = o.id
  u.save
end

Given /^the user with email "(.*?)" has "(.*?)" set to "(.*?)"$/ do |email, field, value|
  u = User.find_by_email email
  assert u.send(field) == value
end

