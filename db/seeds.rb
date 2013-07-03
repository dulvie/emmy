# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Default users, jtest(admin) and ktest(normal user)
jtest = User.new({
  name: "jtest",
  email: "jtest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
jtest.save
jtest.roles.build(name: "admin")

ktest = User.new({
  name: "ktest",
  email: "ktest@mailinator.com",
  password: "foobar",
  password_confirmation: "foobar"
})
ktest.save

ankeborg_warehouse = Warehouse.create({name: "Kvacken", city: "Ankeborg"})

espresso = Product.create({
  name: "Espresso",
  in_price: 3000,
  out_price: 8000,
  customer_price: 9500
})

espresso_in_ankeborg = Slot.new
espresso_in_ankeborg.warehouse = ankeborg_warehouse
espresso_in_ankeborg.product = espresso
espresso_in_ankeborg.save

emmaus = Customer.create({
  name: "Emmaus Stockholm",
})

# Creating an invoice, this is a bit hairy ----------------
invoice = Invoice.new
invoice.customer = emmaus
invoice.user = jtest
invoice.save

item = InvoiceItem.new
item.product = espresso
item.invoice = invoice
item.quantity = 12
item.save

change = SlotChange.new
change.slot = espresso_in_ankeborg
change.user = jtest
change.quantity = -12
change.save

item.slot_change = change
item.save
# End invoice ---------------------------------------------





