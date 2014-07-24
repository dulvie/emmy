# Emmy

### Emmy is an application to handle logistics and invoicing for small organisations that sell some kind of products.

db/seed.rb contains sample data, Don't use this in production!

[dependencies](doc/os_deps)

Everything besides login, about and start page is(should be) locked down using CanCan.

To get into the system, first create a new user using rails console and add the "admin" role to it.

ie:

    $ bundle exec rails console
    > u = User.new :email "me@example.com", :password => "changeme", :password_confirmation => "changeme"
    > u.save
    > u.roles << Role.create :name => "admin
    > u.save

Admins can register new users and select what roles they should have.
