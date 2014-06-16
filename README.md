# DOCKER-POSTGRESQL93

A Docker container for PostgreSQL 9.3.   
TODO: describe some features

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
- `--volume=/mylocaldir:/pgdata`  
The dir /mylocaldir in the host will be mounted to /pgdata in the container.
You can use the local dir /mylocaldir or any other dir, but you must use the container dir /pgdata.
- `-e "PG_USERNAME=myuser"`  
The username to be used when creating a new ROLE in PostgreSQL.
- `-e "PG_PASSWORD=mypass"`  
The password to be used when creating a new ROLE in PostgreSQL.
- `-e "SSH_PUBLIC_KEY=..."`  
The SSH public key to be added to the authorized_keys file in order to accept SSH connections.

### EXAMPLES
```
$ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=..." nimiq/postgresql
```

A more user-friendly input of the public SSH key:
```
$ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
$ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql
```

Run a one-shot interactive shell:
```
$ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
$ docker run -ti --rm -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql /sbin/my_init -- bash
```

To test the PostgreSQL server, you can run from the host:
```
psql -h localhost -p 5432 -U myuser myuser
```

## START/STOP
```
$ docker start postgresql
$ docker stop postgresql
```
