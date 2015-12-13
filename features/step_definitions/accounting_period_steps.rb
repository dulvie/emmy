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

Given /^I click link "([^"]*?)"$/ do |button_string|
  link = find_link(button_string)
  link.trigger('click')
end

Given /^I click button "([^"]*?)"$/ do |button_string|
  link = find_button(button_string)
  link.trigger('click')
end

Given /^I click delete link for "(.*?)" template in "(.*?)"$/ do |supplier_name, org_slug|
  assert true, page.has_content?(supplier_name)
  s = Template.find_by_name supplier_name
  delete_link = find(".delete-icon.template-#{s.id}")
  delete_link.trigger('click')
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{template_path(org_slug, s)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def accounting_period_valid_form_data
  fill_in "accounting_period_name", with: "test accounting period"
  select "BAS – Kontoplan 2014", from: 'accounting_period_accounting_plan_id'
  select "month", from: 'accounting_period_vat_period_type'
end
