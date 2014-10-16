Given /^I click edit link for "(.*?)" batch in "(.*?)"$/ do |batch_name, o|
  assert true, page.has_content?(batch_name)
  b = Batch.find_by_name "test batch"
  assert_equal b.name, batch_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_batch_path(o,b)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" batch in "(.*?)"$/ do |batch_name, org_slug|
  assert true, page.has_content?(batch_name)
  b = Batch.find_by_name batch_name
  delete_link = find(".delete-icon.batch-#{b.id}")
  delete_link.click
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{batch_path(org_slug, b)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

def batch_valid_form_data
  fill_in "batch_name", with: "test batch"
  select "espresso", from: 'batch_item_id'
end

def batch_invalid_form_data
  fill_in "batch_name", with: ""
end
