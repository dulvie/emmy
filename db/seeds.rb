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
roles = Role.create([{ name: "admin"}, {name: "seller"}])
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

ankeborg_warehouse = Warehouse.create({name: "Kvacken", city: "Ankeborg"})
flea_bottom = Warehouse.create({name: "Flea bottom", city: "King's landing"})

unit1 = Unit.create(name: "Paket (1/2 kg)", weight: "1/2 kg")
unit2 = Unit.create(name: "St")
unit3 = Unit.create(name: "Säck (50 kg)", weight: "50 kg")
unit4 = Unit.create(name: "Pall", weight: "100 kg")
unit5 = Unit.create(name: "Tim")

vat0 = Vat.create(name: "Ingen", vat_percent: 0)
vat6 = Vat.create(name: "(6 procent)", vat_percent: 6)
vat12 = Vat.create(name: "(12 procent)", vat_percent: 12)
vat25 = Vat.create(name: "(25 procent)", vat_percent: 25)

espresso_i = Item.create({
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

brewd_i = Item.create({
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
coffe = Item.create({
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

ship = Item.create({
  name: "Skeppning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})
freight = Item.create({
  name: "Frakt",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})

custom = Item.create({
  name: "Tulldeklarering",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat0.id
})
rost = Item.create({
  name: "Rostning",
  item_type: 'purchases',
  item_group: ' ',
  stocked: 'false',
  unit_id: unit2.id,
  vat_id: vat25.id
})

espresso = Product.create({
  item_id: espresso_i.id,
  name: "Espresso 14:1",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
})

brewd = Product.create({
  item_id: brewd_i.id,
  name: "Brygg 14:1",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
})

espresso_b = Batch.create({
  item_id: espresso_i.id,
  name: "Espresso 14:1",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
})

brewd_b = Batch.create({
  item_id: brewd_i.id,
  name: "Brygg 14:1",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
})

espresso_in_ankeborg = Shelf.new
espresso_in_ankeborg.warehouse = ankeborg_warehouse
espresso_in_ankeborg.batch = espresso_b
espresso_in_ankeborg.save

brewd_in_ankeborg = Shelf.new
brewd_in_ankeborg.warehouse = ankeborg_warehouse
brewd_in_ankeborg.batch = brewd_b
brewd_in_ankeborg.save

#[espresso, brewd].each do |pr|
#  product_transaction = ProductTransaction.new(
#    warehouse: ankeborg_warehouse,
#    product: pr,
#    quantity: (10..100).to_a.sample
#  )
#  m = Manual.new
#  m.user = jtest
#  m.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction")
#  m.product_transaction = product_transaction
#  m.save
#end

[espresso_b, brewd_b].each do |batch|
  batch_transaction = BatchTransaction.new(
    warehouse: ankeborg_warehouse,
    batch: batch,
    quantity: (10..100).to_a.sample
  )
  m = Manual.new
  m.user = jtest
  m.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction")
  m.batch_transaction = batch_transaction
  m.save
end

#tr = Transfer.new
#tr.from_warehouse = ankeborg_warehouse
#tr.to_warehouse = flea_bottom
#tr.quantity = 10
#tr.product = espresso
#tr.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction")
#tr.save
#date_now = Time.now
#tr.send_package(date_now)
#tr.receive_package(date_now)


donald = Customer.create(name: "Donald duck", payment_term: 10)
coffehouse = Customer.create(name: 'Coffe House by Foobar', payment_term: 10)
1.upto(15) do |i|
	Customer.create(name: "Kund #{i}", payment_term: 30)
end

bigsupp = Supplier.create(name: "Big supplier of coffee")
coffesupp = Supplier.create(name: "Kaffekooperativ")
freightsupp = Supplier.create(name: "Shipping LTD")
tullsupp = Supplier.create(name: "Tullverket")
rostsupp = Supplier.create(name: "AB Rosteri")


# @TODO create invoice(s)
