Given(/^default_code imported$/) do
  Rails.logger.level = 4
  o = Organization.find_by_name("test organization")
  assert o, "no organization found"
  u = User.find_by_name 'testuser'
  assert u, "no user found"
  a = AccountingPlan.find_by_name "BAS – Kontoplan 2014"
  default_code_creator = Services::DefaultCodeCreator.new(o, u, nil, a)
  default_code_creator.execute('load and connect', DefaultCode::DIRECTORY, 'Default_codes.csv')
end


Then /^I should see (\d+) default_codes connected to accounts in "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  accounts = a.accounts.where('default_code_id NOTNULL')
  assert_equal nbr.to_i, accounts.size
end

def default_code_valid_form_data
  select "Default_codes.csv", from: 'file_importer_file'
  select "reload and connect", from: 'file_importer_type'
  select "BAS – Kontoplan 2014", from: 'file_importer_accounting_plan'
end