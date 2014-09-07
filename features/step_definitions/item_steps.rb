def create_items
  [:espresso, :brew, :raw].each do |name|
    FactoryGirl.create(:item, name: name)
  end
end
