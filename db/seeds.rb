# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Organization
o = Organization.find_or_create_by name: "Default organization"
o2 = Organization.find_or_create_by name: "Check organization"
o3 = Organization.find_or_create_by name: "Demo organization"

jtest = User.new({
  name: "jtest",
  email: "jtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
jtest.default_organization_id = 3
[o,o2,o3].each do |org|
  r = jtest.organization_roles.build(name: OrganizationRole::ROLE_ADMIN)
  r.organization_id = org.id
end

r = jtest.organization_roles.build(name: OrganizationRole::ROLE_SUPERADMIN)
r.organization_id = 0
jtest.save

ktest = User.new({
  name: "ktest",
  email: "ktest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
ktest.default_organization_id = o.id
[o,o2,o3].each do |org|
  r = ktest.organization_roles.build(name: OrganizationRole::ROLE_ADMIN)
  r.organization_id = org.id

end
ktest.save

xtest = User.new({
  name: "xtest",
  email: "xtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
xtest.default_organization_id = o.id
[o,o2].each do |org|
  r = xtest.organization_roles.build(name: OrganizationRole::ROLE_ADMIN)
  r.organization_id = org.id
end
xtest.save


ankeborg_warehouse = Warehouse.new({name: "Kvacken", city: "Ankeborg"})
ankeborg_warehouse.organization = o
ankeborg_warehouse.save
flea_bottom = Warehouse.new({name: "Flea bottom", city: "King's landing"})
flea_bottom.organization = o
flea_bottom.save


unit1 = Unit.new(name: "Paket (1/2 kg)", weight: "1/2 kg")
unit1.organization = o
unit1.save
unit2 = Unit.new(name: "St")
unit2.organization = o
unit2.save
unit3 = Unit.new(name: "Säck (50 kg)", weight: "50 kg")
unit3.organization = o
unit3.save
unit4 = Unit.new(name: "Pall", weight: "100 kg")
unit4.organization = o
unit4.save
unit5 = Unit.new(name: "Tim")
unit5.organization = o
unit5.save
unit6 = Unit.new(name: "Tim i org 2")
unit6.organization = o2
unit6.save


vat0 = Vat.create(name: "Ingen", vat_percent: 0)
vat0.organization = o
vat0.save
vat6 = Vat.create(name: "(6 procent)", vat_percent: 6)
vat6.organization = o
vat6.save
vat12 = Vat.create(name: "(12 procent)", vat_percent: 12)
vat12.organization = o
vat12.save
vat25 = Vat.create(name: "(25 procent)", vat_percent: 25)
vat25.organization = o
vat25.save
vat99 = Vat.create(name: "(30 procent i org 2)", vat_percent: 30)
vat99.organization = o2
vat99.save


espresso_i = Item.new({
  name: "Espresso",
  item_type: 'sales',
  item_group: 'refined',
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
  stocked: 'true',
  unit_id: unit1.id,
  vat_id: vat12.id
})
espresso_i.organization = o
espresso_i.save

brewd_i = Item.new({
  name: "Brygg",
  item_type: 'sales',
  item_group: 'refined',
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
  stocked: 'true',
  unit_id: unit1.id,
  vat_id: vat12.id
})
brewd_i.organization = o
brewd_i.save

coffe = Item.new({
  name: "Råkaffe",
  item_type: 'both',
  item_group: 'unrefined',
  in_price: 6000,
  distributor_price: 6000,
  retail_price: 6000,
  stocked: 'true',
  unit_id: unit3.id,
  vat_id: vat0.id
})
coffe.organization = o
coffe.save

ship = Item.new({
  name: "Skeppning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})
ship.organization = o
ship.save

freight = Item.new({
  name: "Frakt",
  item_type: 'both',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})
freight.organization = o
freight.save

custom = Item.new({
  name: "Tulldeklarering",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})
custom.organization = o
custom.save

rost = Item.new({
  name: "Rostning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat25.id
})
rost.organization = o
rost.save

espresso = Batch.new({
  item_id: espresso_i.id,
  name: "Espresso 14:1",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500
})
espresso.organization = o
espresso.save

brewd = Batch.new({
  item_id: brewd_i.id,
  name: "Brygg 14:1",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500
})
brewd.organization = o
brewd.save

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


donald = Customer.new(name: "Donald duck", payment_term: 10)
donald.organization = o
donald.save
coffeehouse = Customer.new(name: 'Coffe House by Foobar', payment_term: 10)
coffeehouse.organization = o
coffeehouse.save

1.upto(15) do |i|
	c = Customer.new(name: "Kund #{i}", payment_term: 30)
  c.organization = o
  c.save
end

bigsupp = Supplier.new(name: "Big supplier of coffee")
bigsupp.organization = o
bigsupp.save

coffeesupp = Supplier.new(name: "Kaffekooperativ")
coffeesupp.organization = o
coffeesupp.save

freightsupp = Supplier.new(name: "Shipping LTD")
freightsupp.organization = o
freightsupp.save

tullsupp = Supplier.new(name: "Tullverket")
tullsupp.organization = o
tullsupp.save

rostsupp = Supplier.new(name: "AB Rosteri")
rostsupp.organization = o
rostsupp.save

# Accounting plan ---------------------
plan_bas = Services::AccountingPlanCreator.new(o, jtest)
plan_bas.BAS_read_and_save
bas = plan_bas.accounting_plan

# Ink codes ---------------------------
ink_code = Services::InkCodeCreator.new(o, jtest, bas)
ink_code.read_and_save

# Tax codes ---------------------------
tax_code = Services::TaxCodeCreator.new(o, jtest, bas)
tax_code.tax_codes_save
tax_code.BAS_tax_code_update

# Ne codes -----------------------------
ne_code = Services::NeCodeCreator.new(o, jtest)
ne_code.read_and_save

# Accounting period --------------------
ap13 = AccountingPeriod.new({
  name: "Räkenskapsår 2013",
  accounting_from: DateTime.new(2013,01,01),
  accounting_to: DateTime.new(2013,12,31),
  active: 'true',
  accounting_plan: bas,
  vat_period_type: 'month'
})
ap13.organization = o
ap13.save

ap14 = AccountingPeriod.new({
  name: "Räkenskapsår 2014",
  accounting_from: DateTime.new(2014,01,01),
  accounting_to: DateTime.new(2014,12,31),
  active: 'true',
  accounting_plan: bas,
  vat_period_type: 'month'
})
ap14.organization = o
ap14.save

ap15 = AccountingPeriod.new({
  name: "Räkenskapsår 2015",
  accounting_from: DateTime.new(2015,01,01),
  accounting_to: DateTime.new(2015,12,31),
  active: 'false',
  accounting_plan: bas,
  vat_period_type: 'month'
})
ap15.organization = o
ap15.save

# Templates ----------------------------
templates = Services::TemplateCreator.new(o, jtest, bas)
templates.save_templates_bas

# @TODO create invoice(s)
