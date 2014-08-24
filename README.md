macadmins-sal
=============

This Docker image runs [Sal](https://github.com/grahamgilbert/sal). The container expects a linked PostgreSQL database container.

# Settings

Several options, such as the timezone and admin password are customizable using environment variables.

* ``ADMIN_PASS``: The default admin's password. This is only set if there are no other superusers, so if you choose your own admin username and password later on, this won't be created.
* ``DOCKER_SAL_DISPLAY_NAME``: This sets the name that appears in the title bar of the window. Defaults to ``Sal``.
* ``DOCKER_SAL_TZ``: The desired [timezone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Defaults to ``Europe/London``.
* ``DOCKER_SAL_ADMINS``: The admin user's details. Defaults to ``Docker User, docker@localhost``.
* ``DOCKER_SAL_PLUGIN_ORDER``: The order plugins are displayed in. Defaults to ``Activity,Status,OperatingSystem,Uptime,Memory``.

If you require more advanced settings, for example if you want to hide certain plugins from certain Business Units or if you have a plugin that needs settings, you can override ``settings.py`` with your own. A good starting place can be found on this image's [Github repository](https://github.com/grahamgilbert/macadmins-sal/blob/master/settings.py).

# Plugins

The plugins directory is exposed as a volume to the host, so you can add your own plugins. 

#Postgres container

You must run the PostgreSQL container before running the Sal container.
Currently there is support only for PostgreSQL.
I use the [stackbrew postgres container](https://registry.hub.docker.com/_/postgres/) from the Docker Hub, but you can use your own. The app container expects the following environment variables to connect to a database:

* ``DB_NAME``
* ``DB_USER``
* ``DB_PASS``

See [this blog post](http://davidamick.wordpress.com/2014/07/19/docker-postgresql-workflow/) for an example for an example workflow using the postgres container. The setup_db.sh script in the GitHub repo will create the database tables for you. The official guide on [linking containers](https://docs.docker.com/userguide/dockerlinks/) is also very helpful.

```bash
$ docker pull postgres
$ docker run --name="postgres-sal" -d -v /usr/local/sal_data/db:/var/lib/postgresql/data postgres
# Edit the setup.db script from the github repo to change the database name, user and password before running it.
$ ./setup_db.sh
# Or, if you're using the defaults of admin and password
$ bash <(curl -s https://raw.githubusercontent.com/macadmins/sal/master/setup_db.sh)
```

#Running the Sal Container

```bash
$ docker run -d --name="sal" \
  -p 80:8000 \
  --link postgres-sal:db \
  -v /usr/local/sal_data/plugins:/home/app/sal/plugins \
  -v /usr/local/sal_data/settings/settings.py:/home/app/sal/sal/settings.py \
  -e ADMIN_PASS=pass \
  -e DB_NAME=sal \
  -e DB_USER=admin \
  -e DB_PASS=password \
  macadmins/sal
```

#TODO

* Add support for SQLite and MySQL
