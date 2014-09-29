def item_valid_form_data
  fill_in "item_name", with: "test item"
  select "sales", from: 'item_item_type'
  select "kg", from: 'item_unit_id'
  select "12 procent", from: 'item_vat_id'
end

def item_invalid_form_data
  fill_in "item_name", with: ""
end