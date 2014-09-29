def item_valid_form_data
  fill_in "item_name", with: "test item"
  select "sales", from: 'item_item_type'
  select "kg", from: 'item_unit_id'
  select "12 procent", from: 'item_vat_id'
end

def item_invalid_form_data
  fill_in "item_name", with: ""
end

Given /^I click edit link for "(.*?)" item$/ do |item_name|
  assert true, page.has_content?(item_name)
  item = Item.find_by_name item_name
  assert_equal item.name, item_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_item_path(item)}')]")
  assert edit_link
  edit_link.click
end
