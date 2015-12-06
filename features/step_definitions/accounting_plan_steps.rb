Given /^I click edit link for "(.*?)" accounting_plan in "(.*?)"$/ do |accounting_plan, org_slug|
  a = AccountingPlan.find_by_name accounting_plan
  assert a, "no accounting plan found"
  edit_link = find(:xpath, "//a[contains(@href,'#{accounting_plan_path(org_slug, a)}')]")
  edit_link.click
end

Given(/^accounting_plan imported$/) do
  Rails.logger.level = 4
  o = Organization.find_by_name("test organization")
  assert o, "no organization found"
  u = User.find_by_name 'testuser'
  assert u, "no user found"
  accounting_plan = Services::AccountingPlanCreator.new(o, u)
  accounting_plan.read_and_save(AccountingPlan::DIRECTORY, "Kontoplan_Normal_2014_ver1.csv")
end

Then /^I should see (\d+) accounting_classes in "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  assert_equal nbr.to_i, a.accounting_classes.size
end

Then /^I should see (\d+) accounting_groups in "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  assert_equal nbr.to_i, a.accounting_groups.size
end

Then /^I should see (\d+) accounts in "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  assert_equal nbr.to_i, a.accounts.size
end

def accounting_plan_valid_form_data
  select "Kontoplan_Normal_2014_ver1.csv", from: 'file_importer_file'
end