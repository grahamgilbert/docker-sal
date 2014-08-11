macadmins-sal
=============

This Docker container runs [Sal](https://github.com/grahamgilbert/sal).
The container expects a linked PostgreSQL database container.

Several options, such as the timezone and admin password are customizable using environment variables.

#Postgres container
You must run the PostgreSQL container before running the munkiwebadmin container.
Currently there is support only for PostgreSQL.
I use the [stackbrew postgres container](https://registry.hub.docker.com/_/postgres/) from the Docker Hub, but you can use your own. The app container expects the following environment variables to connect to a database:
DB_NAME
DB_USER
DB_PASS

See [this blog post](http://davidamick.wordpress.com/2014/07/19/docker-postgresql-workflow/) for an example for an example workflow using the postgres container.
The setup_db.sh script in the GitHub repo will create the database tables for you.
The official guide on [linking containers](https://docs.docker.com/userguide/dockerlinks/) is also very helpful.

```bash
$ docker pull postgres
$ docker run --name="postgres-sal" -d -v /usr/local/sal_data/db:/var/lib/postgresql/data postgres
# Edit the setup.db script from the github repo to change the database name, user and password before running it.
$ ./setup_db.sh
```

#Image Creation
```$ docker build -t="grahamgilbert/sal" .```

#Running the Sal Container

```bash
$ docker run -d --name="sal" \
  -p 80:8000 \
  --link postgres-sal:db \
  -e ADMIN_PASS=pass \
  -e DB_NAME=sal \
  -e DB_USER=admin \
  -e DB_PASS=password \
  grahamgilbert/sal
```

#TODO
* add support for logging
* add support for sqlite and mysql
* add support for SSL
