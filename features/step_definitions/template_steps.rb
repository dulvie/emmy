Given(/^I check number of templates$/) do
 t = Template.all
 puts "Number of templates #{t.size}"
end

Then /^I should see (\d+) templates for "(.*?)"$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  templates = Template.where('accounting_plan_id = ?', a.id)
  assert_equal nbr.to_i, templates.size
end

Given /^I click "([^"]*?)" for "(.*?)" in "(.*?)"$/ do |button_string, accounting_plan, org_slug|
  # puts "trying to click #{button_string} new"
  a = AccountingPlan.find_by_name accounting_plan
  link = templates_import_path(org_slug) + "?locale=en&accounting_plan_id=" + "#{a.id}"
  # puts link
  # puts page.body
  # /test-organization/templates_import?locale=en&amp;accounting_plan_id=1
  import_link = first(:xpath, "//a[contains(@href,'#{link}')]")
  assert import_link
  import_link.trigger('click')
end

Given /^I click delete link for "(.*?)" template in "(.*?)"$/ do |supplier_name, org_slug|
  assert true, page.has_content?(supplier_name)
  s = Template.find_by_name supplier_name
  delete_link = find(".delete-icon.template-#{s.id}")
  delete_link.trigger('click')
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{template_path(org_slug, s)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def template_valid_form_data
  select "BAS – Kontoplan 2014", from: 'template_accounting_plan_id'
  fill_in "template_name", with: "test name"
  fill_in "template_description", with: "test description"
  select "cost", from: 'template_template_type'
end

def template_item_valid_form_data
  select "1010", from:  'template_item_account_id'
  fill_in "template_item_description", with: "test item description"
  check('Enable debit')
end