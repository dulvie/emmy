# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

o = Organisation.new name: "Default organisation"
o.save

# Default users, jtest(admin) and ktest(normal user)
roles = Role.create([{ name: "admin"}, {name: "seller"}, {name: 'suspended'}])
jtest = User.new({
  name: "jtest",
  email: "jtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
jtest.save
jtest.roles << roles.first
jtest.save

ktest = User.new({
  name: "ktest",
  email: "ktest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
ktest.save
ktest.roles << roles.last
ktest.save

ankeborg_warehouse = Warehouse.create({name: "Kvacken", city: "Ankeborg", organisation: o})
flea_bottom = Warehouse.create({name: "Flea bottom", city: "King's landing", organisation: o})

unit1 = Unit.create(name: "Paket (1/2 kg)", weight: "1/2 kg", organisation: o)
unit2 = Unit.create(name: "St", organisation: o)
unit3 = Unit.create(name: "Säck (50 kg)", weight: "50 kg", organisation: o)
unit4 = Unit.create(name: "Pall", weight: "100 kg", organisation: o)
unit5 = Unit.create(name: "Tim", organisation: o)

vat0 = Vat.create(name: "Ingen", vat_percent: 0, organisation: o)
vat6 = Vat.create(name: "(6 procent)", vat_percent: 6, organisation: o)
vat12 = Vat.create(name: "(12 procent)", vat_percent: 12, organisation: o)
vat25 = Vat.create(name: "(25 procent)", vat_percent: 25, organisation: o)

espresso_i = Item.create({
  name: "Espresso",
  item_type: 'sales',
  item_group: 'refined',
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
  stocked: 'true',
  unit_id: unit1.id,
  vat_id: vat12.id,
  organisation: o
})

brewd_i = Item.create({
  name: "Brygg",
  item_type: 'sales',
  item_group: 'refined',
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
  stocked: 'true',
  unit_id: unit1.id,
  vat_id: vat12.id,
  organisation: o
})
coffe = Item.create({
  name: "Råkaffe",
  item_type: 'both',
  item_group: 'unrefined',
  in_price: 6000,
  distributor_price: 6000,
  retail_price: 6000,
  stocked: 'true',
  unit_id: unit3.id,
  vat_id: vat0.id,
  organisation: o
})

ship = Item.create({
  name: "Skeppning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organisation: o
})
freight = Item.create({
  name: "Frakt",
  item_type: 'both',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organisation: o
})

custom = Item.create({
  name: "Tulldeklarering",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organisation: o
})
rost = Item.create({
  name: "Rostning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat25.id,
  organisation: o
})

espresso = Batch.create({
  item_id: espresso_i.id,
  name: "Espresso 14:1",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
  organisation: o
})

brewd = Batch.create({
  item_id: brewd_i.id,
  name: "Brygg 14:1",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
  organisation: o
})

espresso_in_ankeborg = Shelf.new
espresso_in_ankeborg.warehouse = ankeborg_warehouse
espresso_in_ankeborg.batch = espresso
espresso_in_ankeborg.organisation_id=o.id
espresso_in_ankeborg.save

brewd_in_ankeborg = Shelf.new
brewd_in_ankeborg.warehouse = ankeborg_warehouse
brewd_in_ankeborg.batch = brewd
brewd_in_ankeborg.organisation_id = o.id
brewd_in_ankeborg.save

[espresso, brewd].each do |batch|
  batch_transaction = BatchTransaction.new(
    warehouse: ankeborg_warehouse,
    batch: batch,
    quantity: (10..100).to_a.sample,
    organisation_id: o.id
  )
  m = Manual.new
  m.user = jtest
  m.organisation_id = o.id
  m.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction", organisation: o)
  m.batch_transaction = batch_transaction
  m.save
end

tr = Transfer.new
tr.organisation_id = o.id
tr.from_warehouse = ankeborg_warehouse
tr.to_warehouse = flea_bottom
tr.quantity = 10
tr.batch = espresso
tr.comments.build(user_id: jtest.id, body: "Initial seed manual batch_transaction", organisation: o)
tr.save
date_now = Time.now
tr.send_package(date_now)
tr.receive_package(date_now)


donald = Customer.create(name: "Donald duck", payment_term: 10, organisation: o)
coffehouse = Customer.create(name: 'Coffe House by Foobar', payment_term: 10, organisation: o)
1.upto(15) do |i|
	Customer.create(name: "Kund #{i}", payment_term: 30, organisation: o)
end

bigsupp = Supplier.create(name: "Big supplier of coffee", organisation: o)
coffesupp = Supplier.create(name: "Kaffekooperativ", organisation: o)
freightsupp = Supplier.create(name: "Shipping LTD", organisation: o)
tullsupp = Supplier.create(name: "Tullverket", organisation: o)
rostsupp = Supplier.create(name: "AB Rosteri", organisation: o)


# @TODO create invoice(s)
