# DOCKER-POSTGRESQL93

A [Docker](https://www.docker.com/) container for PostgreSQL 9.3 with *special features*. Available for pulling from the
[Docker Registry](https://registry.hub.docker.com/u/nimiq/postgresql93/).

Features:  
- Based on [Ubuntu 14.04](http://www.ubuntu.com/) and [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
- [PostgreSQL 9.3](http://www.postgresql.org/)
- Automatically create your PostgreSQL *superuser* with the given *password*
- Integrated [SSH server](http://en.wikipedia.org/wiki/Secure_Shell)
- Add your *public key* to the container's SSH server for an easy access
- Expose to the host the *ports* 22 (SSH) and 5432 (PostgreSQL)
- Share PostgreSQL *data directory* and *log files* with the host and other Docker containers

Links:  
- [Docker Registry](https://registry.hub.docker.com/u/nimiq/postgresql93/)
- [Project page](http://painl.es/docker-postgresql/) in my website

## BUILD
```
$ docker build -t nimiq/postgresql .
```

## RUN
### ARGUMENTS
- `-p 2223:22`  
Port 22 (SSH) in the container will be exposed to port 2223 in the host.
You can use the host port 2223 or any other port, but you must use the container port 22.
- `-p 5432:5432`  
Port 5432 (PostgreSQL) in the container will be exposed to port 5432 in the host.
You can use the host port 5432 or any other port, but you must use the container port 5432.
- `--volume=/mylocaldir:/srv/pgdata`  
The dir /mylocaldir in the host will be mounted to /srv/pgdata in the container. This dir must be emtpy.
You can use the local dir /mylocaldir or any other dir, but you must use the container dir /srv/pgdata.
- `-e "PG_USERNAME=myuser"`  
The username to be used when creating a new ROLE in PostgreSQL.
- `-e "PG_PASSWORD=mypass"`  
The password to be used when creating a new ROLE in PostgreSQL.
- `-e "SSH_PUBLIC_KEY=..."`  
The SSH public key to be added to the authorized_keys file in order to accept SSH connections.

### EXAMPLES
```
$ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=..." nimiq/postgresql
```

A more user-friendly input of the public SSH key:
```
$ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
$ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql
```

Run a one-shot interactive shell:
```
$ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
$ docker run -ti --rm -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql /sbin/my_init -- bash
```

## START/STOP
```
$ docker start postgresql
$ docker stop postgresql
```

## SSH, POSTGRESQL CONNECTIONS
To SSH into the container, run from the host:
```
ssh root@127.0.0.1 -p 2223
```

To connect to the PostgreSQL server, run from the host:
```
psql -h localhost -p 5432 -U myuser myuser
```
