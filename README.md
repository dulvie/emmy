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

### Docker environment

The `docker-compose.yml` is not for production use, but can be used for development.

The rubyemmy image can be built from the `Dockerfile` of this repository.

    docker build -t rubyemmy .

Then, you'll need a `docker volume` to persist the database between restarts

    docker create --name emmy-data -v /data -v /var/lib/postgresql/data busybox echo true

To start the env:

    docker-compose up -d


`docker-compose.yml`  is set to use env.development as the environment file.
which means that your local `.env` and `env.development` should look exactly the same
since `.env` is the file used by rails/dotenv

Particular important variables is `DEVISE_PEPPER` and `SECRET_KEY_BASE`
Since all env have different pepper/key\_base, when you import a database from
somewhere else, you will not be able to login. You have to reset the password for the user
you want to use.

This will start redis, postgresql and the rubyemmy container.
`Mailcatcher` is started by default. But the `Emmy` rails application and the resque jobs is
not started by default. those needs to be started manually from within the container.

To enter the running container, first get the `container_id`:

    container_id=docker ps |grep rubyemmy |awk '{print $1}'

Then execute a `bash` shell inside:

    docker exec -ti $container_id bash

Use foreman to run rails and the resque jobs:

    foreman start -f Procfile.local


The default `Procfile` also runs mailcatchers, which the container runs on it self, by default.
This means you have to use a local `Procfile` without the `mailcatcher` row.


Migrations should also be runned from within the `rubyemmy` container.

    rake db:migrate

TO set a new password, you can use:

    bundle exec rake user:new_password

If the environment is not working correctly, try to load the env file:

    . ./.env

or/and

    . ./env.development

or/and

    . /etc/envvars

