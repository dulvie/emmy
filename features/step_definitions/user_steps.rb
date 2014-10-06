def user_valid_form_data
  fill_in "user_email", with: "test@example.com"
  fill_in "user_password", with: "abc123"
  fill_in "user_password_confirmation", with: "abc123"
end

Given /^a user with the email "(.*?)" exists and have the role "(.*?)" on "(.*?)"$/ do |email, role_name, org_name|
  o = Organization.find_by_name org_name
  assert o
  u = FactoryGirl.build(:user, email: email, name: email.gsub('@', ' '))
  u.organization_roles.build(organization_id: o.id, name: 'staff')
  assert u.save
end

