def create_items
  [:espresso].each do |name|
    FactoryBot.create(:item, name: name)
  end
end

def item_valid_form_data
  fill_in "item_name", with: "test item"
  select "sales", from: 'item_item_type'
  select "kg", from: 'item_unit_id'
  select "12 procent", from: 'item_vat_id'
end

def item_invalid_form_data
  fill_in "item_name", with: ""
end

Given /^I click edit link for "(.*?)" item in "(.*?)"$/ do |item_name, org_name|
  assert true, page.has_content?(item_name)
  item = Item.find_by_name item_name
  assert_equal item.name, item_name
  edit_link = find(:xpath, "//a[contains(@href,'#{edit_item_path(org_name, item)}')]")
  assert edit_link
  edit_link.click
end

Given /^I click delete link for "(.*?)" item in "(.*?)"$/ do |item_name, org_slug|
  assert true, page.has_content?(item_name)
  itm = Item.find_by_name item_name
  delete_link = find(".delete-icon.item-#{itm.id}")
  delete_link.click
  delete_link_confirm = find(:xpath, "//a[contains(@href,'#{item_path(org_slug, itm)}') and contains (@data-method, 'delete')]")
  delete_link_confirm.click
end

