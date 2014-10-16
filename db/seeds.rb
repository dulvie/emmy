# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Organization
o = Organization.new name: "Default organization"
o.save
o2 = Organization.new name: "Check organization"
o2.save
o3 = Organization.new name: "Demo organization"
o3.save

jtest = User.new({
  name: "jtest",
  email: "jtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
jtest.default_organization_id = 3
jtest.organization_roles.build(organization_id: 0, name: OrganizationRole::ROLE_SUPERADMIN)
jtest.organization_roles.build(organization_id: o.id, name: OrganizationRole::ROLE_ADMIN)
jtest.organization_roles.build(organization_id: o2.id, name: OrganizationRole::ROLE_ADMIN)
jtest.organization_roles.build(organization_id: o3.id, name: OrganizationRole::ROLE_ADMIN)
jtest.save

ktest = User.new({
  name: "ktest",
  email: "ktest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
ktest.default_organization_id = o.id
ktest.organization_roles.build(organization_id: o.id, name: OrganizationRole::ROLE_ADMIN)
ktest.organization_roles.build(organization_id: o2.id, name: OrganizationRole::ROLE_STAFF)
ktest.organization_roles.build(organization_id: o3.id, name: OrganizationRole::ROLE_STAFF)
ktest.save

xtest = User.new({
  name: "xtest",
  email: "xtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
xtest.default_organization_id = o.id
xtest.organization_roles.build(organization_id: o.id, name: OrganizationRole::ROLE_ADMIN)
xtest.organization_roles.build(organization_id: o2.id, name: OrganizationRole::ROLE_STAFF)
xtest.save

ankeborg_warehouse = Warehouse.create({name: "Kvacken", city: "Ankeborg", organization: o})
flea_bottom = Warehouse.create({name: "Flea bottom", city: "King's landing", organization: o})

unit1 = Unit.create(name: "Paket (1/2 kg)", weight: "1/2 kg", organization: o)
unit2 = Unit.create(name: "St", organization: o)
unit3 = Unit.create(name: "Säck (50 kg)", weight: "50 kg", organization: o)
unit4 = Unit.create(name: "Pall", weight: "100 kg", organization: o)
unit5 = Unit.create(name: "Tim", organization: o)
unit6 = Unit.create(name: "Tim i org 2", organization: o2)

vat0 = Vat.create(name: "Ingen", vat_percent: 0, organization: o)
vat6 = Vat.create(name: "(6 procent)", vat_percent: 6, organization: o)
vat12 = Vat.create(name: "(12 procent)", vat_percent: 12, organization: o)
vat25 = Vat.create(name: "(25 procent)", vat_percent: 25, organization: o)
vat99 = Vat.create(name: "(30 procent i org 2)", vat_percent: 30, organization: o2)

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
  organization: o
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
  organization: o
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
  organization: o
})

ship = Item.create({
  name: "Skeppning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organization: o
})
freight = Item.create({
  name: "Frakt",
  item_type: 'both',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organization: o
})

custom = Item.create({
  name: "Tulldeklarering",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id,
  organization: o
})
rost = Item.create({
  name: "Rostning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat25.id,
  organization: o
})

espresso = Batch.create({
  item_id: espresso_i.id,
  name: "Espresso 14:1",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
  organization: o
})

brewd = Batch.create({
  item_id: brewd_i.id,
  name: "Brygg 14:1",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
  organization: o
})

espresso_in_ankeborg = Shelf.new
espresso_in_ankeborg.warehouse = ankeborg_warehouse
espresso_in_ankeborg.batch = espresso
espresso_in_ankeborg.organization_id=o.id
espresso_in_ankeborg.save

brewd_in_ankeborg = Shelf.new
brewd_in_ankeborg.warehouse = ankeborg_warehouse
brewd_in_ankeborg.batch = brewd
brewd_in_ankeborg.organization_id = o.id
brewd_in_ankeborg.save

[espresso, brewd].each do |batch|
  batch_transaction = BatchTransaction.new(
    warehouse: ankeborg_warehouse,
    batch: batch,
    quantity: (10..100).to_a.sample,
    organization_id: o.id
  )
  m = Manual.new
  m.user = jtest
  m.organization_id = o.id
  m.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction", organization: o)
  m.batch_transaction = batch_transaction
  m.save
end

tr = Transfer.new
tr.organization_id = o.id
tr.from_warehouse = ankeborg_warehouse
tr.to_warehouse = flea_bottom
tr.quantity = 10
tr.batch = espresso
tr.comments.build(user_id: jtest.id, body: "Initial seed manual batch_transaction", organization: o)
tr.save
date_now = Time.now
tr.send_package(date_now)
tr.receive_package(date_now)


donald = Customer.create(name: "Donald duck", payment_term: 10, organization: o)
coffehouse = Customer.create(name: 'Coffe House by Foobar', payment_term: 10, organization: o)
1.upto(15) do |i|
	Customer.create(name: "Kund #{i}", payment_term: 30, organization: o)
end

bigsupp = Supplier.create(name: "Big supplier of coffee", organization: o)
coffesupp = Supplier.create(name: "Kaffekooperativ", organization: o)
freightsupp = Supplier.create(name: "Shipping LTD", organization: o)
tullsupp = Supplier.create(name: "Tullverket", organization: o)
rostsupp = Supplier.create(name: "AB Rosteri", organization: o)


# @TODO create invoice(s)
