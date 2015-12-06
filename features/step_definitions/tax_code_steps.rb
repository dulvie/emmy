Given /^I click edit link for "(.*?)" accounting_plan in "(.*?)"$/ do |accounting_plan, org_slug|
  a = AccountingPlan.find_by_name accounting_plan
  assert a, "no accounting plan found"
  edit_link = find(:xpath, "//a[contains(@href,'#{accounting_plan_path(org_slug, a)}')]")
  edit_link.click
end

Given(/^tax_code imported$/) do
  Rails.logger.level = 4
  o = Organization.find_by_name("test organization")
  assert o, "no organization found"
  u = User.find_by_name 'testuser'
  assert u, "no user found"
  a = AccountingPlan.find_by_name "BAS – Kontoplan 2014"
  tax_code_creator = Services::TaxCodeCreator.new(o, u, nil, a)
  tax_code_creator.execute('load and connect', TaxCode::DIRECTORY, 'TAX_codes.csv')
end

Then /^I should see (\d+) tax_codes connected to accounts in "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  accounts = a.accounts.where('tax_code_id NOTNULL')
  assert_equal nbr.to_i, accounts.size
end

def tax_code_valid_form_data
  select "TAX_codes.csv", from: 'file_importer_file'
  select "reload and connect", from: 'file_importer_type'
  select "BAS – Kontoplan 2014", from: 'file_importer_accounting_plan'
end