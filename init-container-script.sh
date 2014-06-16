#!/bin/bash

# This script will be executed once on a `docker run`.

# Create a new PostgreSQL user.
create_pg_user () {
    # Create the given user in PostgreSQL. 
    # If the user already exists PostgreSQL will return an error, but we don't care.
    echo "CREATE USER $PG_USERNAME WITH SUPERUSER PASSWORD '$PG_PASSWORD';" | su - postgres -c "psql"
    echo "CREATE DATABASE $PG_USERNAME OWNER $PG_USERNAME;" | su - postgres -c "psql"
}

# Add $SSH_PUBLIC_KEY to the authorized_keys file.
add_ssh_key () {
    if grep -q "$SSH_PUBLIC_KEY" ~/.ssh/authorized_keys
    then
        # Do nothing if the key is already there.
        echo "The SSH public key already exists"
    else
        # Add the key if not already there.
        echo $SSH_PUBLIC_KEY >> /root/.ssh/authorized_keys
    fi
}

# Move PostgreSQL data folder to the shared volume.
move_postgresql_data_to_shared_volume () {
    # Test if /var/lib/postgresql/9.3/main is a symlink.
    if [[ -L "/var/lib/postgresql/9.3/main" ]]
    then
        echo "Data have already been moved."
    else
        # Change the ownership of the folder.
        mkdir -p /pgdata/data
        mkdir -p /pgdata/logs
        chown -R postgres:postgres /pgdata

        # Stop PostgreSQL.
        service postgresql stop

        # Ensure postgresql is stopped and the dirs are empty.
        service postgresql status
        if [ $? = 3 ] && [ ! "$(ls -A /pgdata/data)" ] && [ ! "$(ls -A /pgdata/logs)" ]
        then
            # Move the data dir to the mounted volume.
            su - postgres -c "mv /var/lib/postgresql/9.3/main /pgdata/data"
            su - postgres -c "ln -s /pgdata/data/main /var/lib/postgresql/9.3/main"

            # Move the logs to the mounted volume.
            mv /var/log/postgresql /pgdata/logs
            ln -s /pgdata/logs/postgresql /var/log/postgresql

            echo "PostgreSQL data moved, symlinks created."
        else
            echo "/pgdata/data or /pgdata/logs are not empty dirs. Operation aborted."
        fi

        # Start PostgreSQL.
        service postgresql start
    fi  
}

# STEP 1: add the given SSH public key.
# During a `docker run` the environment variable SSH_PUBLIC_KEY must be passed.
# This key will be added to the authorized_keys of the SSH server of the container.
# This way the key's owner is allowed to SSH into the container.
echo " * Adding public SSH key..." 
if [ ! -z "$SSH_PUBLIC_KEY" ]  # If the env var $SSH_PUBLIC_KEY is set.
then
    add_ssh_key
fi

# STEP 2: create the given PostgreSQL user.
# During a `docker run` the environment variable PG_USERNAME and PG_PASSWORD must be passed.
echo " * Creating PostgreSQL user $PG_USERNAME..."
if [ ! -z "$PG_USERNAME" ] && [ ! -z "$PG_PASSWORD"  ]
then
    create_pg_user
fi

# STEP 3: move PostgreSQL data folder to the shared volume.
# Ensure /pgdata is mounted, which means the container was run with:
# docker run ... --volume=/localpath:/pgdata ...
echo " * Moving PostgreSQL data..."
if [[ ! "$(mount)" =~ \ /pgdata\ type ]]
then
    echo "There is no mounted volume"
else
    move_postgresql_data_to_shared_volume
fi