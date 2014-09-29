Given /^I click edit link for "(.*?)" batch$/ do |batch_name|
  assert true, page.has_content?(batch_name)
  wh = Batch.find_by_name "test batch"
  assert_equal wh.name, batch_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_batch_path(wh)}')]")
  edit_link.click
end

Given /^I click delete link for "(.*?)" batch$/ do |batch_name|
  assert true, page.has_content?(batch_name)
  wh = Batch.find_by_name batch_name
  delete_link = find(:xpath, "//a[contains(@href,'#{batch_path(wh)}') and contains (@data-method, 'delete')]")
  delete_link.click
end

def batch_valid_form_data
  fill_in "batch_name", with: "test batch"
  select "espresso", from: 'batch_item_id'
end

def batch_invalid_form_data
  fill_in "batch_name", with: ""
end
