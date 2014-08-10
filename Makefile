DOCKER_USER=grahamgilbert
ADMIN_PASS=pass
SAL_PORT=8000
DB_NAME=sal
DB_PASS=password
DB_USER=admin
DB_CONTAINER_NAME:=postgres-sal
NAME:=sal
DOCKER_RUN_COMMON=--name="$(NAME)" -p ${SAL_PORT}:8000 --link $(DB_CONTAINER_NAME):db -e ADMIN_PASS=${ADMIN_PASS} -e DB_NAME=$(DB_NAME) -e DB_USER=$(DB_USER) -e DB_PASS=$(DB_PASS) ${DOCKER_USER}/sal


all: build

build:
	docker build --no-cache=true -t="${DOCKER_USER}/sal" .

run:
	docker run -d ${DOCKER_RUN_COMMON}

interactive:
	docker run -i ${DOCKER_RUN_COMMON}

bash:
	docker run -t -i ${DOCKER_RUN_COMMON} /bin/bash

clean:
	docker stop $(NAME)
	docker rm $(NAME)
	docker rmi ${DOCKER_USER}/${NAME}

postgres:
	mkdir -p /tmp/postgres
	docker run --name="${DB_CONTAINER_NAME}" -d -v /tmp/postgres/:/var/lib/postgresql postgres

postgres-clean:
	docker stop $(DB_CONTAINER_NAME)
	docker rm $(DB_CONTAINER_NAME)