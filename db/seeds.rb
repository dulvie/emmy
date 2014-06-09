# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


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

espresso = Product.create({
  name: "Espresso",
  in_price: 3000,
  distributor_price: 8000,
  retail_price: 9500,
  vat: 12
})

brewd = Product.create({
  name: "Brygg",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500,
  vat: 12
})

coffe = Product.create({
  name: "Råkaffe",
  in_price: 6000,
  distributor_price: 6000,
  retail_price: 6000,
  vat: 0
})

freight = Product.create({
  name: "Skeppning",
  in_price: 3000,
  distributor_price: 3000,
  retail_price: 3000,
  vat: 0
})

custom = Product.create({
  name: "Tulldeklarering",
  in_price: 3000,
  distributor_price: 3000,
  retail_price: 3000,
  vat: 0
})
rost = Product.create({
  name: "Rostning",
  in_price: 3000,
  distributor_price: 3000,
  retail_price: 3000,
  vat: 0
})
espresso_in_ankeborg = Shelf.new
espresso_in_ankeborg.warehouse = ankeborg_warehouse
espresso_in_ankeborg.product = espresso
espresso_in_ankeborg.save

brewd_in_ankeborg = Shelf.new
brewd_in_ankeborg.warehouse = ankeborg_warehouse
brewd_in_ankeborg.product = brewd
brewd_in_ankeborg.save

[espresso, brewd].each do |pr|
  product_transaction = ProductTransaction.new(
    warehouse: ankeborg_warehouse,
    product: pr,
    quantity: (10..100).to_a.sample
  )
  m = Manual.new
  m.user = jtest
  m.comments.build(user_id: jtest.id, body: "Initial seed manual product_transaction")
  m.save
  product_transaction.parent = m
  product_transaction.save
end

tr = Transfer.new
tr.from_warehouse = ankeborg_warehouse
tr.to_warehouse = flea_bottom
tr.quantity = 10
tr.product = espresso
tr.save
tr.send_package
tr.receive_package


donald = Customer.create(name: "Donald duck")
coffehouse = Customer.create(name: 'Coffe House by Foobar')
1.upto(15) do |i|
	Customer.create(name: "Kund #{i}")
end

bigsupp = Supplier.create(name: "Big supplier of coffee")
coffesupp = Supplier.create(name: "Kaffekooperativ")
freightsupp = Supplier.create(name: "Shipping LTD")
tullsupp = Supplier.create(name: "Tullverket")

# @TODO create invoice(s)
