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
  retail_price: 9500
})

brewd = Product.create({
  name: "Brygg",
  in_price: 3000,
  distributor_price: 6000,
  retail_price: 6500
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
  transaction = Transaction.new(
    warehouse: ankeborg_warehouse,
    product: pr,
    quantity: (5..100).to_a.sample
  )
  transaction.parent = Manual.new user: jtest
  transaction.save
end


donald = Customer.create(name: "Donald duck")

coffehouse = Customer.create(name: 'Coffe House by Foobar')

# @TODO create invoice(s)
